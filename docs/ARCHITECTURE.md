# Cosmira — Architecture Overview

## Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (Auth, Database, Edge Functions, Storage, Realtime)
- **Database**: PostgreSQL (via Supabase)
- **AI**: Google Gemini API (daily generation), OpenAI API (premium deep reports)
- **Astrology**: Swiss Ephemeris (via native FFI / Dart port)
- **Payments**: RevenueCat (wraps Apple/Google subscriptions + Stardust tokens)
- **Ads**: Google AdMob (rewarded only)
- **Analytics**: Firebase Analytics + Crashlytics
- **Notifications**: Firebase Cloud Messaging + Supabase Edge Functions
- **Music**: Spotify Web API

## Architecture Pattern
Clean Architecture with Feature-First folder organization.

```
lib/
├── core/           # Shared utilities, theme, networking, widgets
├── features/       # Feature modules (each has data/domain/presentation)
├── config/         # Environment, DI, app config
├── router/         # GoRouter navigation
└── main.dart       # Entry point
```

Each feature follows:
```
feature/
├── data/
│   ├── datasources/   # Remote (Supabase) + Local (Hive/SharedPrefs)
│   ├── models/        # JSON-serializable DTOs
│   └── repositories/  # Repository implementations
├── domain/
│   ├── entities/      # Pure business objects
│   ├── repositories/  # Abstract repository contracts
│   └── usecases/      # Single-responsibility business logic
└── presentation/
    ├── screens/       # Full page widgets
    ├── widgets/       # Feature-specific UI components
    └── providers/     # Riverpod providers / state
```

## State Management
Riverpod 2.x with code generation. AsyncNotifier for async state, NotifierProvider for synchronous state.

## Caching Strategy
- **Cache-first**: All AI reports cached in Supabase DB
- **Natal chart**: Computed once, stored permanently
- **Daily horoscope**: Generated once per day per sign, shared across users
- **Reports**: Cached with TTL, revalidated on meaningful transit changes
- **Images/Assets**: Cached via CachedNetworkImage + Hive

## Cost Optimization
- Daily horoscopes: 12 Gemini calls/day (one per sign), served to all users
- Natal charts: One-time computation, cached forever
- Premium reports: OpenAI only, Stardust-gated, cached 90 days
- Target: <$0.20 infra cost per $1 revenue

## Security
- Row Level Security (RLS) on all Supabase tables
- API keys in environment variables (--dart-define)
- Supabase Edge Functions for sensitive AI calls
- JWT validation on all protected endpoints
- No client-side secret exposure
