# Cosmira UI Skills

Rules to follow when adding a card, button, screen, or any UI component.

---

## Grid Cards (`quick_action_grid.dart`)

Two card types — pick the right one:

| Type | Use when | Widget |
|---|---|---|
| **Grid tile** (2-column) | Short description + icon + label + action button | `_ExploreTile` |
| **Full-width banner** | Feature that stands alone with richer layout | `_AstrocartographyBanner` style |

**Adding a grid tile:**
- Append a new `_ExploreTile` to the `children` list inside `GridView.count`.
- Always provide either `emoji` or `iconData`, never both.
- Pick an unused color from `AppColors` aura palette. Never repeat a color already used by another tile.
- Do not change `childAspectRatio: 1.15` — shorten the description instead if content overflows.

**Adding a banner:**
- Place it above or below the `GridView`, never inside it.
- Separate it from the grid with `SizedBox(height: 12)`.
- Layout: `GestureDetector → Container(padding: all(16), borderRadius: 20) → Row([emoji, SizedBox(16), Expanded(Column([title, desc])), SizedBox(12), action button])`.

---

## Card Content Alignment

**`CosmicCard` (`lib/core/widgets/cosmic_card.dart`)**
- Default padding is `all(20)` — use the `padding:` parameter if you need to override, don't wrap with another Container.
- Content always starts with `Column(crossAxisAlignment: CrossAxisAlignment.start)`.
- Title: `AppTextStyles.titleMedium`. Body: `AppTextStyles.bodyMedium` with `AppColors.textSecondary`.
- Spacing between stacked cards: `SizedBox(height: 12)` or `SizedBox(height: 16)` — don't mix values.

**Grid tile inner order (always this sequence):**
```
SizedBox(height: 32, child: icon)   ← fixed height keeps icons aligned
SizedBox(height: 8)
Text(label)                          ← titleMedium, white
SizedBox(height: 6)
Expanded(child: Text(description))  ← bodySmall, textSecondary, maxLines: 3
SizedBox(height: 8)
action label container
```
`Expanded` is required — removing it causes overflow.

---

## Premium & Pro Feature Cards

**Subscription-gated features** — use the ready-made widget:
```dart
PremiumUpsellCard(
  title: 'Feature Name',
  subtitle: 'This feature requires Premium',
)
```
- Always uses `AppColors.premiumGradient`. Don't change it.
- Always navigates to `/paywall` on tap. Don't change it.

**Check pattern inside a screen:**
```dart
if (!profile.isPremium) {
  return const PremiumUpsellCard();
}
// ... actual content
```

**Stardust-gated features** — use `CosmicButton` with `stardustCost`:
```dart
CosmicButton(
  label: 'Unlock Feature',
  stardustCost: 50,
  onPressed: () { ... },
)
```

Inline cost badge (inside a card, outside a button):
```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text('$cost', style: AppTextStyles.labelSmall.copyWith(color: AppColors.auraAmber)),
    const SizedBox(width: 3),
    const Icon(Icons.auto_awesome, color: AppColors.auraAmber, size: 9),
  ],
)
```

---

## Stardust Currency Display

`Icons.auto_awesome` is the stardust icon. **The icon always goes to the RIGHT of the number.**

```dart
// ✓ Correct
Row(children: [
  Text('$balance'),
  SizedBox(width: 4),
  Icon(Icons.auto_awesome, color: AppColors.auraAmber, size: 16),
])

// ✗ Wrong
Row(children: [
  Icon(Icons.auto_awesome ...),
  Text('$balance'),
])
```

> Exception: `StardustHeader` (the balance pill in the top bar) shows the icon on the left — that's intentional for the balance indicator only. Don't replicate this pattern elsewhere.

Size guide:

| Context | Icon size | Text style |
|---|---|---|
| Inline cost badge inside a card | 9 px | `labelSmall`, `auraAmber` |
| Cost badge inside a button | 14 px | `labelSmall`, `auraAmber` |
| Header balance pill | 16 px | `stardustBalance.copyWith(fontSize: 14)` |
| Large balance display | 20+ px | `stardustBalance` |

---

## Preventing Mobile Overflow

- Any `Text` inside a `Row` must be wrapped in `Expanded` or `Flexible`.
- Every card description needs `maxLines` + `overflow: TextOverflow.ellipsis`.
- Never use fixed-width constraints on text — let it flex.
- If a page's root is `Scaffold(body: Column(...))`, wrap it in `SingleChildScrollView` unless it's a scrollable list.
- Don't shrink `childAspectRatio` to fix overflow — fix the content instead.

---

## Adding New Components

**Buttons — always use `CosmicButton`**, never raw `ElevatedButton` or `TextButton`:
```dart
CosmicButton(label: 'Continue', onPressed: () { })           // primary (gradient)
CosmicButton(label: 'Cancel', isPrimary: false, onPressed: () { })  // secondary (border)
CosmicButton(label: 'Unlock', stardustCost: 100, onPressed: () { }) // stardust cost
CosmicButton(label: 'View Map', icon: Icons.map, onPressed: () { }) // with icon
CosmicButton(label: 'Loading...', isLoading: true)                  // loading state
```

**Cards — always use `CosmicCard`**, never a raw decorated `Container`:
```dart
CosmicCard(onTap: () { ... }, child: ...)
```

**Haptic feedback** — every tappable tile or custom gesture must call `HapticUtils.light()` inside `onTap`. `CosmicButton` already does this; don't forget it in custom tiles.

**Animations** — use this template for newly added widgets:
```dart
MyWidget().animate().fadeIn(delay: 300.ms).slideY(begin: 0.08)
```
Stagger delays by `+100ms` per element, starting from 200ms, capping at 600ms.

---

## Color Reference

```
AppColors.auraViolet   #8B5CF6  → Natal chart
AppColors.auraRose     #FB7185  → Compatibility
AppColors.auraTeal     #2DD4BF  → Breathwork
AppColors.auraIndigo   #6366F1  → Moon rituals
AppColors.auraAmber    #FBBF24  → Stardust / warnings
AppColors.auraEmerald  #34D399  → Success / available for new features
Color(0xFF0EA5E9)              → Astrocartography (banner only, do not reuse)
Color(0xFFE879F9)              → Numerology (banner only, do not reuse)
```

When adding a new feature, pick an unused color from the list above. Never define inline hex colors — the two banner exceptions are legacy and should not be replicated.
