# Frontend Architecture Documentation

## Overview

This document explains the complete architecture of the Flutter web frontend application, which serves as a unified hub for two projects: **Daily Utility Tool** and **Minima (URL Shortener)**. The architecture follows a modular, scalable design pattern that allows easy addition of new projects.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Design Patterns](#design-patterns)
4. [State Management](#state-management)
5. [Routing System](#routing-system)
6. [API Integration](#api-integration)
7. [Component Structure](#component-structure)
8. [Theme & Styling](#theme--styling)
9. [Key Features](#key-features)
10. [Adding New Projects](#adding-new-projects)

---

## Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter Web App                           │
│                   (MaterialApp + GoRouter)                       │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
        ┌───────────▼──────────┐  ┌────────▼───────────┐
        │  Daily Utility Tool  │  │  Minima (URL       │
        │     Project          │  │   Shortener)       │
        └───────────┬──────────┘  └────────┬───────────┘
                    │                      │
        ┌───────────┴──────────┐  ┌────────┴───────────┐
        │                      │  │                     │
        │  • QR Generator      │  │  • Link Shortener  │
        │  • Barcode Gen       │  │  • Analytics       │
        │  • Unit Converter    │  │  • QR for Links    │
        │  • Age Calculator    │  │  • History         │
        │  • EMI Calculator    │  │                    │
        │                      │  │                    │
        └──────────────────────┘  └────────────────────┘
```

### Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Framework** | Flutter 3.10+ | Cross-platform UI framework |
| **Language** | Dart 3.10+ | Type-safe programming |
| **State Management** | Riverpod 2.6.1 | Reactive state management |
| **Routing** | GoRouter 14.8.1 | Declarative routing |
| **HTTP Client** | Dio 5.9.0 | API communication |
| **UI Components** | Material 3 | Design system |
| **Charts** | FL Chart 0.68.0 | Data visualization |
| **Icons** | Lucide Flutter 1.17.0 | Modern icon set |
| **Fonts** | Google Fonts 6.2.1 | Typography |
| **Animations** | Flutter Animate 4.5.0 | Smooth transitions |

---

## Project Structure

### Directory Tree

```
Daily_Utility_Tool_Frontend/
│
├── lib/
│   ├── main.dart                      # App entry point
│   │
│   ├── api_services/                  # API layer
│   │   ├── Daily_Utility_Tool/
│   │   │   ├── api_routes.dart        # API endpoints
│   │   │   └── services/              # Service classes
│   │   │       ├── qr_code_services.dart
│   │   │       ├── barcode_services.dart
│   │   │       ├── unit_converter_services.dart
│   │   │       ├── age_services.dart
│   │   │       └── emi_services.dart
│   │   │
│   │   └── Minima/
│   │       ├── link_service.dart      # URL shortener API
│   │       └── share_helper.dart      # Social sharing
│   │
│   ├── models/                        # Data models
│   │   ├── Daily_Utility_Tool/
│   │   │   ├── qr_code_model.dart
│   │   │   ├── barcode_models.dart
│   │   │   ├── unit_converter_models.dart
│   │   │   ├── age_model.dart
│   │   │   └── emi_models.dart
│   │   │
│   │   └── Minima/
│   │       └── link_model.dart
│   │
│   ├── notifiers/                     # State notifiers (Riverpod)
│   │   ├── Daily_Utility_Tool/
│   │   └── Minima/
│   │       ├── link_notifier.dart
│   │       └── history_notifier.dart
│   │
│   ├── providers/                     # Riverpod providers
│   │   ├── Daily_Utility_Tool/
│   │   └── Minima/
│   │
│   ├── routes/                        # Routing configuration
│   │   ├── app_router.dart           # Main router
│   │   ├── Daily_Utility_Tool/
│   │   │   ├── app_router.dart       # Project routes
│   │   │   └── app_pages.dart        # Route definitions
│   │   │
│   │   └── Minima/
│   │       ├── app_router.dart
│   │       └── app_pages.dart
│   │
│   ├── screens/                       # Full-page views
│   │   ├── main_home_screen.dart     # Landing page
│   │   │
│   │   ├── Daily_Utility_Tool/
│   │   │   ├── qr_generator_screen.dart
│   │   │   ├── barcode_generator_screen.dart
│   │   │   ├── unit_converter_screen.dart
│   │   │   ├── age_calculator_screen.dart
│   │   │   └── emi_calculator_screen.dart
│   │   │
│   │   └── Minima/
│   │       ├── landing_screen.dart   # URL shortener home
│   │       └── dashboard_screen.dart # Analytics dashboard
│   │
│   ├── widgets/                       # Reusable components
│   │   ├── Daily_Utility_Tool/
│   │   │   ├── qr_generator/
│   │   │   ├── barcode_generator/
│   │   │   ├── unit_converter/
│   │   │   ├── age_calculator/
│   │   │   └── emi_calculator/
│   │   │
│   │   └── Minima/
│   │       ├── shorten_form.dart     # URL input form
│   │       ├── history_list.dart     # Link history
│   │       └── glass_container.dart  # UI component
│   │
│   ├── cards/                         # Card components
│   │   └── Daily_Utility_Tool/
│   │       ├── qr_generator_card.dart
│   │       ├── barcode_card.dart
│   │       └── ...
│   │
│   ├── theme/
│   │   └── app_theme.dart            # Theme configuration
│   │
│   └── features/                      # Feature modules (future)
│       └── link/
│           └── presentation/
│               └── screens/
│
├── assets/
│   └── images/                        # Image assets
│
├── web/
│   ├── index.html                     # Web entry point
│   ├── manifest.json                  # PWA manifest
│   └── icons/                         # App icons
│
├── android/                           # Android platform
├── ios/                               # iOS platform
├── linux/                             # Linux platform
├── macos/                             # macOS platform
├── windows/                           # Windows platform
│
├── pubspec.yaml                       # Dependencies
├── analysis_options.yaml              # Linter config
└── README.md                          # Documentation
```

---

## Design Patterns

### 1. **Modular Architecture**

Each project (Daily Utility Tool, Minima) is organized as a **self-contained module**:

```
Project Module Structure:
├── api_services/<ProjectName>/  # API layer
├── models/<ProjectName>/        # Data models
├── notifiers/<ProjectName>/     # State management
├── providers/<ProjectName>/     # Provider definitions
├── routes/<ProjectName>/        # Routing
├── screens/<ProjectName>/       # Pages
└── widgets/<ProjectName>/       # Components
```

**Benefits:**
- Clear separation of concerns
- Easy to add new projects
- No cross-contamination between projects
- Independent testing

### 2. **Layered Architecture**

```
┌─────────────────────────────────────┐
│         Presentation Layer          │  (Screens, Widgets)
├─────────────────────────────────────┤
│         Business Logic Layer        │  (Notifiers, Providers)
├─────────────────────────────────────┤
│            Data Layer               │  (Models, Services)
├─────────────────────────────────────┤
│           Network Layer             │  (Dio, API)
└─────────────────────────────────────┘
```

### 3. **Feature-First Structure** (Future)

For larger features, use feature-first organization:

```
features/
└── link/
    ├── data/
    │   ├── repositories/
    │   └── models/
    ├── domain/
    │   ├── entities/
    │   └── use_cases/
    └── presentation/
        ├── screens/
        ├── widgets/
        └── notifiers/
```

---

## State Management

### Riverpod Architecture

The app uses **Riverpod 2.6+** for reactive state management.

#### Provider Types Used

| Type | Use Case | Example |
|------|----------|---------|
| **StateNotifierProvider** | Complex state management | `linksProvider`, `historyProvider` |
| **Provider** | Read-only values | `apiServiceProvider` |
| **FutureProvider** | Async data | API calls |
| **StreamProvider** | Real-time data | WebSocket (future) |

#### Example: Link Management

```dart
// Notifier - Business Logic
class LinksNotifier extends StateNotifier<List<LinkModel>> {
  LinksNotifier() : super([]);

  Future<LinkModel> shortenUrl(String url, {String? customAlias}) async {
    // Call API
    final link = await LinkService.shortenUrl(url, customAlias);
    
    // Update state
    state = [...state, link];
    
    return link;
  }

  Future<Map<String, dynamic>> getStats(String shortCode) async {
    return await LinkService.getStats(shortCode);
  }
}

// Provider - State Exposure
final linksProvider = StateNotifierProvider<LinksNotifier, List<LinkModel>>(
  (ref) => LinksNotifier(),
);

// Widget - State Consumption
class SomeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(linksProvider);
    
    return ListView.builder(
      itemCount: links.length,
      itemBuilder: (context, index) => LinkTile(links[index]),
    );
  }
}
```

### State Flow Diagram

```
User Action
    ↓
Widget (Consumer)
    ↓
ref.read(provider.notifier).method()
    ↓
Notifier (Business Logic)
    ↓
API Service
    ↓
HTTP Request → Backend
    ↓
Response
    ↓
Update State (state = newState)
    ↓
Widget Rebuilds Automatically
```

---

## Routing System

### GoRouter Configuration

The app uses **declarative routing** with GoRouter.

#### Route Structure

```
/                            → Main Home Screen
│
├── /daily-utility
│   ├── /qr-generator        → QR Generator Screen
│   ├── /barcode-generator   → Barcode Generator Screen
│   ├── /unit-converter      → Unit Converter Screen
│   ├── /age-calculator      → Age Calculator Screen
│   └── /emi-calculator      → EMI Calculator Screen
│
└── /minima
    ├── /                    → Landing Screen (URL Shortener)
    └── /dashboard           → Analytics Dashboard
```

#### Router Implementation

```dart
// Main Router (app_router.dart)
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'main-home',
        builder: (context, state) => const MainHomeScreen(),
      ),
      
      // Spread project-specific routes
      ...dailyUtilityToolRoutes,
      ...minimaRoutes,
    ],
  );
}

// Project Router (Daily_Utility_Tool/app_router.dart)
final dailyUtilityToolRoutes = [
  GoRoute(
    path: '/daily-utility/qr-generator',
    name: DailyUtilityToolRoutes.qrGenerator,
    builder: (context, state) => const QRGeneratorScreen(),
  ),
  // ... more routes
];
```

#### Navigation Examples

```dart
// Navigate to route
context.go('/daily-utility/qr-generator');

// Navigate with name
context.goNamed(DailyUtilityToolRoutes.qrGenerator);

// Navigate with parameters
context.go('/minima/dashboard?code=abc123');

// Go back
context.pop();
```

---

## API Integration

### API Layer Architecture

```
Widget
  ↓
Consumer (Riverpod)
  ↓
Notifier/Provider
  ↓
API Service Class
  ↓
Dio HTTP Client
  ↓
Backend API
```

### API Service Pattern

```dart
// Service Class
class QRCodeServices {
  static final Dio _dio = Dio();

  static void initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    _dio.interceptors.add(PrettyDioLogger());
  }

  Future<QRResponse> generateQRCode(QRRequest request) async {
    final response = await _dio.post(
      qrCodeGenerateEndpoint,
      data: request.toJson(),
    );
    return QRResponse.fromJson(response.data);
  }
}
```

### API Endpoints Configuration

```dart
// api_routes.dart
const String apiBaseUrl = 'http://192.168.1.6';

// Daily Utility Tool Endpoints
const String qrCodeGenerateEndpoint = '/api/v1/qr/generate';
const String barcodeGenerateEndpoint = '/api/v1/barcodes/generate';
const String unitConverterConvertEndpoint = '/api/v1/converter/convert';

// Minima Endpoints
const String shortenEndpoint = '/shorten';
const String statsEndpoint = '/{shortCode}/stats';
```

### Error Handling

```dart
try {
  final result = await service.makeRequest();
  return result;
} catch (e) {
  if (e is DioException) {
    if (e.response?.statusCode == 400) {
      throw CustomException('Bad Request: ${e.response?.data}');
    } else if (e.response?.statusCode == 500) {
      throw CustomException('Server Error');
    }
  }
  throw CustomException('Network Error');
}
```

---

## Component Structure

### Screen Components

**Full-page views that contain:**
- AppBar/Header
- Body with business logic
- Navigation
- State management

```dart
class QRGeneratorScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends ConsumerState<QRGeneratorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(...),
      body: Column(
        children: [
          QRInputForm(),
          QRPreview(),
          QRActions(),
        ],
      ),
    );
  }
}
```

### Widget Components

**Reusable UI pieces:**
- Forms
- Cards
- Buttons
- Dialogs
- Custom painters

```dart
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;

  const GlassContainer({
    required this.child,
    this.padding,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor ?? Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: child,
    );
  }
}
```

### Card Components

**Pre-built feature cards for home screen:**

```dart
class QRGeneratorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/daily-utility/qr-generator'),
      child: Card(
        child: Column(
          children: [
            Icon(LucideIcons.qrCode),
            Text('QR Generator'),
            Text('Create custom QR codes'),
          ],
        ),
      ),
    );
  }
}
```

---

## Theme & Styling

### Material 3 Theme

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFFDCAEAD),  // Muted rose
    brightness: Brightness.light,
  ).copyWith(
    primary: Color(0xFF4A4A4A),     // Dark gray
    secondary: Color(0xFFDCAEAD),   // Muted rose
    surface: Color(0xFFFBF8F6),     // Off-white
    error: Color(0xFFC62828),       // Red
  ),
  
  scaffoldBackgroundColor: Color(0xFFFBF8F6),
  textTheme: GoogleFonts.montserratTextTheme(),
  
  cardTheme: CardThemeData(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
)
```

### Project-Specific Themes

#### Daily Utility Tool Theme
- **Colors**: Soft pastels (rose, off-white, dark gray)
- **Typography**: Montserrat (clean, modern)
- **Borders**: Rounded (12-24px)
- **Shadows**: Subtle elevations
- **Style**: Minimalist, professional

#### Minima (URL Shortener) Theme
- **Colors**: Dark gradient (charcoal to black) with golden accents
- **Typography**: Sans-serif, bold
- **Effects**: Glassmorphism, glow effects
- **Style**: Futuristic, premium

### Responsive Design

```dart
// Breakpoints
const double mobileBreakpoint = 640;
const double tabletBreakpoint = 1024;
const double desktopBreakpoint = 1440;

// Responsive widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) return mobile;
    if (width < tabletBreakpoint) return tablet ?? mobile;
    return desktop;
  }
}
```

---

## Key Features

### Daily Utility Tool Features

#### 1. **QR Code Generator**
- Multiple QR types (URL, email, phone, WiFi, etc.)
- Auto-detection of input type
- Customizable size, colors, shapes
- Error correction levels
- Frame and logo support
- Download as PNG/SVG

#### 2. **Barcode Generator**
- Multiple formats (Code128, EAN13, UPC, etc.)
- Customizable dimensions
- Download and print support

#### 3. **Unit Converter**
- Multiple categories (length, weight, temperature, etc.)
- Real-time conversion
- History tracking

#### 4. **Age Calculator**
- Precise age calculation
- Next birthday countdown
- Zodiac sign
- Life statistics

#### 5. **EMI Calculator**
- Loan calculations
- Amortization schedules
- Prepayment analysis
- Loan comparison
- Eligibility calculator

### Minima Features

#### 1. **URL Shortening**
- Custom aliases
- Expiry dates
- QR code generation
- Social sharing

#### 2. **Analytics**
- Click tracking
- Device breakdown
- Real-time stats
- Geographic data (future)

#### 3. **Link Management**
- History tracking
- Link editing (future)
- Bulk operations (future)

---

## Adding New Projects

### Step-by-Step Guide

#### 1. Create Project Folder Structure

```
lib/
├── api_services/NewProject/
├── models/NewProject/
├── notifiers/NewProject/
├── providers/NewProject/
├── routes/NewProject/
├── screens/NewProject/
└── widgets/NewProject/
```

#### 2. Define Routes

```dart
// routes/NewProject/app_router.dart
final newProjectRoutes = [
  GoRoute(
    path: '/new-project',
    name: NewProjectRoutes.home,
    builder: (context, state) => const NewProjectScreen(),
  ),
];
```

#### 3. Register Routes in Main Router

```dart
// routes/app_router.dart
import 'NewProject/app_router.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/', ...),
      ...dailyUtilityToolRoutes,
      ...minimaRoutes,
      ...newProjectRoutes,  // Add here
    ],
  );
}
```

#### 4. Add Project Card to Home Screen

```dart
// screens/main_home_screen.dart
ProjectCard(
  title: "New Project",
  description: "Project description",
  icon: LucideIcons.star,
  onTap: () => context.go('/new-project'),
)
```

#### 5. Create API Service

```dart
// api_services/NewProject/new_project_service.dart
class NewProjectService {
  static final Dio _dio = Dio();
  
  Future<Data> fetchData() async {
    final response = await _dio.get('/api/endpoint');
    return Data.fromJson(response.data);
  }
}
```

#### 6. Create State Management

```dart
// notifiers/NewProject/data_notifier.dart
class DataNotifier extends StateNotifier<List<Data>> {
  DataNotifier() : super([]);
  
  Future<void> loadData() async {
    final data = await NewProjectService().fetchData();
    state = data;
  }
}

final dataProvider = StateNotifierProvider<DataNotifier, List<Data>>(
  (ref) => DataNotifier(),
);
```

---

## Best Practices

### Code Organization

1. **One widget per file**
2. **Group related files in folders**
3. **Use meaningful names**
4. **Keep files under 300 lines**
5. **Extract reusable widgets**

### State Management

1. **Use providers for shared state**
2. **Keep notifiers focused**
3. **Avoid unnecessary rebuilds**
4. **Use `select()` for partial state**
5. **Dispose resources properly**

### API Integration

1. **Centralize API configuration**
2. **Handle errors gracefully**
3. **Show loading states**
4. **Cache when appropriate**
5. **Use typed models**

### Performance

1. **Use `const` constructors**
2. **Lazy load heavy widgets**
3. **Optimize images**
4. **Minimize rebuilds**
5. **Profile regularly**

### Accessibility

1. **Add semantic labels**
2. **Support screen readers**
3. **Ensure color contrast**
4. **Support keyboard navigation**
5. **Test with accessibility tools**

---

## Build & Deployment

### Development

```bash
# Run on Chrome
flutter run -d chrome

# Hot reload enabled
r

# Hot restart
R
```

### Build for Production

```bash
# Web
flutter build web --release

# Android
flutter build apk --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release
```

### Environment Configuration

```dart
// config/environment.dart
abstract class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.6',
  );
}

// Run with environment variable
flutter run --dart-define=API_BASE_URL=https://api.production.com
```

---

## Testing Strategy

### Unit Tests

```dart
test('QRService generates correct QR data', () {
  final service = QRService();
  final result = service.generateQR('https://example.com');
  
  expect(result.qrType, equals('url'));
  expect(result.data, isNotEmpty);
});
```

### Widget Tests

```dart
testWidgets('QRGeneratorScreen displays input field', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: QRGeneratorScreen()),
    ),
  );
  
  expect(find.byType(TextField), findsOneWidget);
});
```

### Integration Tests

```dart
testWidgets('End-to-end QR generation flow', (tester) async {
  // 1. Load app
  await tester.pumpWidget(MyApp());
  
  // 2. Navigate to QR generator
  await tester.tap(find.text('QR Generator'));
  await tester.pumpAndSettle();
  
  // 3. Enter data
  await tester.enterText(find.byType(TextField), 'https://test.com');
  
  // 4. Generate QR
  await tester.tap(find.text('Generate'));
  await tester.pumpAndSettle();
  
  // 5. Verify QR is displayed
  expect(find.byType(QrImageView), findsOneWidget);
});
```

---

## Troubleshooting

### Common Issues

#### 1. **Provider Not Found**

**Error**: `ProviderNotFoundException`

**Solution**: Wrap app with `ProviderScope`
```dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}
```

#### 2. **Route Not Found**

**Error**: `Could not find a generator for route`

**Solution**: Register route in `app_router.dart`

#### 3. **API Connection Failed**

**Error**: `DioException: Connection refused`

**Solution**: 
- Check backend is running
- Verify API base URL
- Check CORS headers

#### 4. **State Not Updating**

**Issue**: Widget not rebuilding on state change

**Solution**: Use `ConsumerWidget` or `Consumer`
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);
    return Text(data);
  }
}
```

---

## Future Enhancements

### Planned Features

- [ ] **User Authentication**: Login/signup system
- [ ] **Cloud Sync**: Save user data to cloud
- [ ] **Dark Mode**: Theme switcher
- [ ] **PWA Support**: Install as app
- [ ] **Offline Mode**: Local storage
- [ ] **Analytics Dashboard**: Advanced charts
- [ ] **Notification System**: Real-time alerts
- [ ] **Multi-language**: i18n support
- [ ] **API Key Management**: For third-party integrations
- [ ] **Export/Import**: Data portability

### Architecture Improvements

- [ ] **Clean Architecture**: Domain-driven design
- [ ] **Dependency Injection**: GetIt integration
- [ ] **Repository Pattern**: Abstract data sources
- [ ] **Use Cases**: Business logic layer
- [ ] **GraphQL**: Alternative to REST
- [ ] **WebSocket**: Real-time features

---

## Summary

This frontend architecture provides:

✅ **Modularity**: Easy to add new projects  
✅ **Scalability**: Handle growing feature set  
✅ **Maintainability**: Clear structure and patterns  
✅ **Testability**: Isolated components  
✅ **Performance**: Optimized rendering  
✅ **Developer Experience**: Hot reload, clear patterns  

The key strength is the **project-based modular structure** that allows multiple independent applications to coexist in a single codebase while maintaining clean separation and reusability.

---

**Last Updated**: June 28, 2026  
**Version**: 1.0.0  
**Flutter Version**: 3.10.4  
**Dart Version**: 3.10.4
