# Cosmira — Claude Context

AI-powered spiritual lifestyle app (Flutter + Supabase). Targets iOS, Android, and Web.

---

## Commands

```bash
# Run (env vars required)
flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...

# Analyze
flutter analyze

# Supabase — query remote DB
supabase db query --linked "SELECT ..."

# Supabase — deploy an edge function
supabase functions deploy <function-name> --project-ref bxuborwyihdhztngspko

# Supabase — push a new migration
supabase db push --linked
```

Supabase project ref: `bxuborwyihdhztngspko` (eu-west-1, linked).  
Local Docker is not used — always target the remote project with `--linked`.

---

## Environment Variables

All secrets are injected at compile time via `--dart-define`. Never hardcode them.  
Defined in `lib/config/env.dart` as `String.fromEnvironment(...)`.

| Key | Used for |
|---|---|
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anon key |
| `GOOGLE_CLIENT_ID` | Google Sign-In |
| `GEMINI_API_KEY` | Gemini AI (astrology insights) |
| `OPENAI_API_KEY` | OpenAI (premium reports) |
| `REVENUECAT_API_KEY` | Subscription management |
| `ADMOB_BANNER_ID` / `ADMOB_REWARDED_ID` | AdMob ads |

---

## Architecture

Feature-first folder structure under `lib/features/<feature>/`:

```
data/
  models/        ← JSON ↔ entity mapping (fromJson/toJson)
  repositories/  ← implements domain repository, calls Supabase
domain/
  entities/      ← plain Dart classes (Equatable), no Flutter deps
  repositories/  ← abstract interfaces
presentation/
  providers/     ← Riverpod providers
  screens/       ← full pages
  widgets/       ← page-specific widgets
```

Shared code lives in `lib/core/` (theme, widgets, utils, errors).  
Router is in `lib/router/app_router.dart`. DI is in `lib/config/di.dart`.

---

## Key Patterns

### Result type

All repository methods return `Result<T>` — never throw, never return nullable raw values.

```dart
Future<Result<int>> getBalance(String userId) async {
  try {
    final data = await _client.from('stardust_wallets')...;
    return Result.success(data['balance'] as int);
  } catch (e) {
    return Result.failure(ServerFailure(e.toString()));
  }
}
```

Callers use `.when(success: ..., failure: ...)`.

### Failure types (`lib/core/errors/failures.dart`)

```
ServerFailure            ← Supabase / network errors
AuthFailure              ← authentication errors
CacheFailure             ← local storage errors
NetworkFailure           ← no connectivity
InsufficientStardustFailure(required, available)
SubscriptionRequiredFailure
```

Add new failures here when a domain-specific error is needed.

### Riverpod providers

- `Provider` for repos and services.
- `StreamProvider` for real-time data (auth state, profile, stardust balance).
- `AsyncNotifierProvider` for controllers with async actions (auth, etc.).
- Read providers with `ref.watch` in widgets, `ref.read` in callbacks.

### Supabase RPC calls

Prefer RPC functions for atomic DB operations (stardust spend/earn, daily check-in, referral claim). Never do multi-step mutations from the client.

```dart
final result = await _client.rpc('earn_stardust', params: {
  'p_user_id': userId,
  'p_amount': amount,
  'p_source': 'reward',       // enum: purchase | reward | spend | refund | bonus
  'p_description': '...',
});
```

---

## Data Model — Key Tables

| Table | Purpose |
|---|---|
| `profiles` | User profile, birth data, subscription tier, onboarding flag |
| `stardust_wallets` | One row per user, holds current balance |
| `stardust_transactions` | Ledger of all stardust earn/spend events |
| `natal_charts` | Calculated natal chart per user (cached forever) |
| `cached_reports` | AI-generated reports (birth map, compatibility) with TTL |
| `daily_horoscopes` | Pre-generated daily horoscopes by sign |
| `compatibility_partners` | User's saved partner profiles |
| `user_streaks` | Daily check-in streak tracking |

---

## UserProfile

`lib/features/auth/domain/entities/user_profile.dart`

Important getters:
```dart
bool get isPremium       => subscriptionTier != 'free';
bool get hasBirthData    => birthDate != null && birthTime != null && birthCity != null;
bool onboardingComplete  // set to true after onboarding screen is completed
```

Gate premium features with `isPremium`, stardust features with `hasBirthData` where applicable.

---

## Localization

Two locales: `en` and `tr`. Files in `assets/translations/`.  
Always add both keys when adding new UI text. Use `'key'.tr()` (easy_localization).  
Font: **Satoshi** — always use `AppTextStyles.*`, never raw `TextStyle` with fontSize.

---

## Supabase Edge Functions

Located in `supabase/functions/`. All written in TypeScript (Deno).

| Function | Trigger |
|---|---|
| `calculate-natal-chart` | Called from client after onboarding |
| `generate-big-three-insight` | Called on natal chart page load |
| `generate-birth-map` | Called when user unlocks birth map |
| `generate-house-insights` | Called on birth map page |
| `generate-daily-horoscopes` | Scheduled (cron), not called from client |
| `generate-compatibility-report` | Called when user views compatibility |
| `generate-premium-report` | Called for premium users only |

---

## Auth Flow

```
Login (/login)
  ├── Google Sign-In  → session set → redirect to /
  ├── Apple Sign-In   → session set → redirect to /
  └── Email + Password
        ├── Sign Up → needs email confirmation → /confirm-email
        └── Sign In → session set → redirect to /

/ (HomeScreen)
  └── if !onboardingComplete → show onboarding card → /onboarding
        └── after completion → onboardingComplete = true → back to /
```

Router (`app_router.dart`) guards all routes. Auth state comes from `supabase.auth.onAuthStateChange` stream via `_GoRouterRefreshStream`.

---

## UI Conventions

See `SKILLS.md` for detailed rules. Quick summary:
- Cards: `CosmicCard`. Buttons: `CosmicButton`. Never raw `Container`/`ElevatedButton`.
- Stardust icon (`Icons.auto_awesome`, `AppColors.auraAmber`) always goes **right of the number**.
- Premium gate: `PremiumUpsellCard` → navigates to `/paywall`.
- All `Text` inside `Row` must be wrapped in `Expanded`.
- `HapticUtils.light()` on every tappable tile.
- Animations: `.animate().fadeIn(delay: Xms).slideY(begin: 0.08)`.
