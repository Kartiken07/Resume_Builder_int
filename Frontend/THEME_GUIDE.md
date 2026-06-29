# Theme Centralization Guide

All styling in this Flutter project is now centralized in `lib/theme/app_theme.dart`. Every color, spacing, font size, border radius, shadow, and component size is defined there.

## How to Change Themes

Edit **only** `lib/theme/app_theme.dart` to change any visual aspect of the app. No need to touch individual screens, widgets, or cards.

### Quick Reference

#### Colors
```dart
AppTheme.primary          // Near-white text/icons
AppTheme.accent           // Gold highlights
AppTheme.secondary        // Muted slate
AppTheme.background       // Deep navy background
AppTheme.surface          // Card surface
AppTheme.textPrimary      // Primary text color
AppTheme.border           // Border color
```

#### Typography
```dart
AppTheme.headingLarge     // 54px Playfair Display
AppTheme.titleMedium      // 16px Montserrat
AppTheme.bodyLarge        // 16px body text
AppTheme.labelMedium      // 12px labels
AppTheme.decorative       // Great Vibes script
```

#### Spacing
```dart
AppTheme.spacingSmall     // 8px
AppTheme.spacingMedium    // 16px
AppTheme.spacingLarge     // 24px
AppTheme.spacingXLarge    // 32px
```

#### Border Radius
```dart
AppTheme.radiusSmall      // 8px
AppTheme.radiusMedium     // 12px
AppTheme.radiusLarge      // 16px
AppTheme.radiusXLarge     // 24px
```

#### Shadows
```dart
AppTheme.shadowSmall
AppTheme.shadowMedium
AppTheme.shadowLarge
AppTheme.sidebarShadow
```

#### Component Sizes
```dart
AppTheme.buttonHeight         // 42px
AppTheme.sidebarWidth         // 220px
AppTheme.cardPaddingH         // 20px
AppTheme.cardPaddingV         // 16px
AppTheme.chartHeight          // 180px
```

## Files Updated

All these files now use **only** AppTheme constants:

### Screens (6 files)
- ✅ `lib/screens/dashboard_screen.dart`
- ✅ `lib/screens/unit_converter_screen.dart`
- ✅ `lib/screens/barcode_generator_screen.dart`
- ✅ `lib/screens/age_calculator_screen.dart`
- ✅ `lib/screens/qr_generator_screen.dart`
- ✅ `lib/screens/emi_calculator_screen.dart`

### Widgets (10 files)
- ✅ `lib/widgets/app_shell.dart`
- ✅ `lib/widgets/app_scaffold.dart`
- ✅ `lib/widgets/age_calculator/age_date_picker_tile.dart`
- ✅ `lib/widgets/barcode_generator/barcode_input_field.dart`
- ✅ `lib/widgets/barcode_generator/barcode_type_selector.dart`
- ✅ `lib/widgets/emi_calculator/emi_input_field.dart`
- ✅ `lib/widgets/qr_generater/primary_action_button.dart`
- ✅ `lib/widgets/qr_generater/qr_input_field.dart`
- ✅ `lib/widgets/qr_generater/qr_size_selector.dart`
- ✅ `lib/widgets/unit_converter/category_selector.dart`
- ✅ `lib/widgets/unit_converter/unit_dropdown.dart`
- ✅ `lib/widgets/unit_converter/value_input_field.dart`

### Cards (6 files)
- ✅ `lib/cards/age_calculator/age_result_card.dart`
- ✅ `lib/cards/barcode_generator/barcode_result_card.dart`
- ✅ `lib/cards/emi_calculator/emi_breakdown_card.dart`
- ✅ `lib/cards/emi_calculator/emi_value_card.dart`
- ✅ `lib/cards/QR_code/qr_result_card.dart`
- ✅ `lib/cards/unit_converter/conversion_result_card.dart`

## Example: Changing the Accent Color

Want to change from gold to blue accents?

```dart
// In lib/theme/app_theme.dart
static const Color accent = Color(0xFF3B82F6);      // Blue
static const Color accentLight = Color(0xFF60A5FA); // Light blue
static const Color accentDark = Color(0xFF2563EB);  // Dark blue
```

That's it! All buttons, highlights, active states, and decorative elements will update automatically.

## Example: Changing Button Size

```dart
// In lib/theme/app_theme.dart
static const double buttonHeight = 50.0; // Make buttons taller
```

All buttons across all screens will resize.

## Example: Switching to Light Theme

Change these in `lib/theme/app_theme.dart`:

```dart
static const Color background = Color(0xFFF8FAFC);  // Light gray
static const Color surface = Color(0xFFFFFFFF);     // White
static const Color textPrimary = Color(0xFF0F172A); // Dark text
static const Color border = Color(0xFFE2E8F0);      // Light border
```

The entire app switches to light mode.

## Benefits

✅ **Single source of truth** - change once, update everywhere  
✅ **Consistent design** - no random hardcoded values  
✅ **Easy theming** - switch themes by editing one file  
✅ **Maintainable** - clear organization of all design tokens  
✅ **Type-safe** - compile-time checking of all values
