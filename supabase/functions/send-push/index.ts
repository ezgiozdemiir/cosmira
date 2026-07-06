// Supabase Edge Function: Send Push
// Called by the client (NotificationService._insert, see
// lib/features/notifications/domain/services/notification_service.dart)
// right after a notification_log row is created for the current user.
// Looks up that user's registered devices (device_tokens table) and sends
// each one a push via the FCM HTTP v1 API, authenticated with a Firebase
// service account (FCM_SERVICE_ACCOUNT_JSON secret — see
// `supabase secrets set`). Dead tokens (FCM reports UNREGISTERED/NOT_FOUND)
// are pruned so device_tokens doesn't accumulate stale rows.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FCM_SERVICE_ACCOUNT_JSON = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface ServiceAccount {
  client_email: string;
  private_key: string;
  project_id: string;
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

function base64url(input: string | ArrayBuffer): string {
  const raw = typeof input === "string"
    ? input
    : String.fromCharCode(...new Uint8Array(input));
  return btoa(raw).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function getAccessToken(serviceAccount: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claim = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const unsigned = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(claim))}`;

  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(serviceAccount.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${base64url(signature)}`;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });
  const data = await res.json();
  if (!res.ok) throw new Error(`OAuth token error: ${JSON.stringify(data)}`);
  return data.access_token as string;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Authorization required" }),
        { status: 401, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid token" }),
        { status: 401, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    const body = await req.json();
    const { user_id, title, body: messageBody, data } = body as {
      user_id?: string;
      title?: string;
      body?: string;
      data?: Record<string, unknown>;
    };

    if (!user_id || !title || !messageBody) {
      return new Response(
        JSON.stringify({ error: "user_id, title and body are required" }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    // This endpoint only ever sends a notification the caller just created
    // for themselves — never pushes to another user.
    if (user_id !== user.id) {
      return new Response(
        JSON.stringify({ error: "forbidden" }),
        { status: 403, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    if (!FCM_SERVICE_ACCOUNT_JSON) {
      // Push not configured yet — fail soft so notification creation itself
      // is never blocked on this.
      return new Response(
        JSON.stringify({ sent: 0, skipped: "FCM_SERVICE_ACCOUNT_JSON not set" }),
        { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    const { data: tokens, error: tokensError } = await supabase
      .from("device_tokens")
      .select("id, token")
      .eq("user_id", user_id);

    if (tokensError) throw new Error(`STEP_TOKENS_FETCH: ${tokensError.message}`);
    if (!tokens || tokens.length === 0) {
      return new Response(
        JSON.stringify({ sent: 0 }),
        { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    const serviceAccount: ServiceAccount = JSON.parse(FCM_SERVICE_ACCOUNT_JSON);
    const accessToken = await getAccessToken(serviceAccount);
    const stringData = Object.fromEntries(
      Object.entries(data ?? {}).map(([k, v]) => [k, String(v)]),
    );

    let sent = 0;
    for (const row of tokens) {
      const res = await fetch(
        `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${accessToken}`,
          },
          body: JSON.stringify({
            message: {
              token: row.token,
              notification: { title, body: messageBody },
              data: stringData,
              android: { priority: "high" },
              apns: { payload: { aps: { sound: "default" } } },
            },
          }),
        },
      );

      if (res.ok) {
        sent++;
        continue;
      }

      const errBody = await res.json().catch(() => ({}));
      const status = errBody?.error?.status;
      if (status === "UNREGISTERED" || status === "NOT_FOUND" || status === "INVALID_ARGUMENT") {
        await supabase.from("device_tokens").delete().eq("id", row.id);
      } else {
        console.error("send-push FCM error:", JSON.stringify(errBody));
      }
    }

    return new Response(
      JSON.stringify({ sent, total: tokens.length }),
      { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  } catch (error) {
    const msg = error instanceof Error ? error.message : JSON.stringify(error);
    console.error("send-push error:", msg);
    return new Response(
      JSON.stringify({ error: msg }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }
});
