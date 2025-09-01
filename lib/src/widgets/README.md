# App Icon Widget

This directory contains the custom app icon widget that matches the design from the home page.

## Usage

The `AppIcon` widget provides three variants:

### 1. AppIcon (Default)
```dart
const AppIcon(
  size: 48,
  backgroundColor: Colors.white.withValues(alpha: 0.2),
  iconColor: Colors.white,
  borderRadius: 16,
)
```

### 2. GradientAppIcon
```dart
const GradientAppIcon(
  size: 48,
  iconColor: Colors.white,
  borderRadius: 16,
)
```

### 3. SolidAppIcon
```dart
const SolidAppIcon(
  size: 48,
  backgroundColor: Color(0xFF3B82F6),
  iconColor: Colors.white,
  borderRadius: 16,
)
```

## Design Features

- **Consistent Design**: Matches the QR code container from the home page
- **Responsive Sizing**: All dimensions scale proportionally with the size parameter
- **Multiple Variants**: Choose between transparent, gradient, or solid backgrounds
- **Customizable**: Colors, size, and border radius can be customized

## Platform Integration

The app icon has been integrated into both Android and iOS platforms:

- **Android**: Updated vector drawables in `android/app/src/main/res/drawable/`
- **iOS**: Ready for PNG generation (requires manual PNG creation for App Store)

## Colors Used

- Primary Blue: `#3B82F6`
- Dark Blue: `#1D4ED8`
- White: `#FFFFFF`
- White with Alpha: `Colors.white.withValues(alpha: 0.2)`
