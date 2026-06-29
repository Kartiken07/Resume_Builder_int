# Daily Utility Tools - Frontend

A modern, feature-rich Flutter Web application providing essential financial calculators and utility tools with a clean, intuitive interface.

## 📋 Overview

Daily Utility Tools is a comprehensive web-first Flutter application built with scalable architecture and Material 3 design principles. The app provides powerful financial calculators and utility tools, all integrated with a robust backend API for accurate calculations.

### Key Highlights

- 🎨 **Modern UI/UX** - Clean, responsive design with smooth animations
- 🔌 **Backend Integration** - All features connected to FastAPI backend
- 📱 **Web-First** - Optimized for desktop and mobile browsers
- 🏗️ **Scalable Architecture** - Well-organized, maintainable codebase
- ⚡ **State Management** - Efficient state handling with Riverpod
- 🎯 **Type-Safe Routing** - Clean navigation with GoRouter

---

## ✨ Features

### 1. **QR Code Generator**
Generate QR codes with customization options:
- Text or URL input
- Multiple size options (Small, Medium, Large)
- Instant preview
- Download QR image
- Copy text to clipboard
- Input validation and error handling

### 2. **Barcode Generator**
Create various types of barcodes:
- **11 Barcode Types**: Code128, Code39, EAN13, EAN8, UPC-A, ITF, Codabar, Code93, DataMatrix, PDF417, QRCode
- Real-time preview with base64 image rendering
- Backend-generated high-quality barcodes
- Download capability
- Type-specific validation

### 3. **Age Calculator**
Calculate age with detailed analytics:
- Precise age calculation (years, months, days)
- Next birthday countdown
- Total days, weeks, and hours lived
- Day of birth (weekday)
- Zodiac sign
- Working days vs weekends
- Life progress percentage
- Historical events on birth date
- Famous people with same birthday
- Planetary age across solar system
- Timezone support

### 4. **Unit Converter**
Convert between various units:
- **Multiple Categories**: Length, Weight, Temperature, Volume, Area, Time, Speed, Digital Storage
- Real-time conversion
- Swap functionality
- Precise calculations
- Clean, intuitive interface

### 5. **EMI Calculator Suite**
Comprehensive loan calculation tools with **6 advanced features**:

#### 5.1 Basic EMI Calculator
- Calculate monthly EMI payments
- Input: Loan amount, interest rate, tenure, frequency
- Visual breakdown with pie chart
- Shows: EMI, total interest, total payment

#### 5.2 Amortization Schedule
- Month-by-month payment breakdown
- Principal vs interest distribution
- Remaining balance tracking
- Summary totals
- Group by year option

#### 5.3 Prepayment Analysis
- Add multiple prepayment scenarios
- See tenure saved for each prepayment
- Calculate interest savings
- Compare impact of different prepayment strategies

#### 5.4 Reverse Calculations
Three calculation modes:
- **Loan Amount**: "How much can I borrow?" (given target EMI)
- **Required Rate**: "What rate do I need?" (given target EMI)
- **Tenure**: "How long will it take?" (given target EMI)

#### 5.5 Loan Eligibility
- Calculate maximum eligible loan amount
- Based on monthly income and FOIR (Fixed Obligation to Income Ratio)
- Accounts for existing EMI obligations
- Shows max affordable EMI
- Professional eligibility report

#### 5.6 Loan Comparison
- Compare multiple loan options side-by-side
- Automatic ranking by total cost
- Visual indicators (🏆 for best deal)
- Shows cost difference from cheapest option
- EMI, interest, and total payment comparison

---

## 🛠️ Tech Stack

### Core Technologies
- **Flutter Web** - Google's UI toolkit for building web applications
- **Dart** ^3.10.4 - Programming language

### State Management & Architecture
- **flutter_riverpod** ^2.6.1 - Reactive state management
- **go_router** ^14.8.1 - Declarative routing

### UI & Design
- **google_fonts** ^6.2.1 - Beautiful typography
- **flutter_animate** ^4.5.0 - Smooth animations
- **lucide_flutter** ^1.17.0 - Modern icon set
- **fl_chart** ^0.68.0 - Charts and data visualization

### Backend Integration
- **dio** ^5.9.0 - HTTP client for API requests
- **pretty_dio_logger** ^1.4.0 - API request/response logging
- **http** ^1.2.1 - HTTP utilities

### Utility Packages
- **qr_flutter** ^4.1.0 - QR code generation
- **barcode_widget** ^2.0.4 - Barcode rendering
- **universal_html** ^2.2.4 - Web compatibility
- **cupertino_icons** ^1.0.8 - iOS-style icons

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── routes/
│   ├── app_router.dart               # Route configuration
│   └── app_pages.dart                # Route constants
├── screens/
│   ├── dashboard_screen.dart         # Home screen
│   ├── qr_generator_screen.dart      # QR code feature
│   ├── barcode_generator_screen.dart # Barcode feature
│   ├── age_calculator_screen.dart    # Age calculator
│   ├── unit_converter_screen.dart    # Unit conversion
│   └── emi_calculator_screen_new.dart # EMI calculator with tabs
├── widgets/
│   ├── app_shell.dart                # Main layout wrapper
│   ├── qr_generator/                 # QR-specific widgets
│   ├── barcode_generator/            # Barcode-specific widgets
│   ├── age_calculator/               # Age calculator widgets
│   ├── unit_converter/               # Unit converter widgets
│   └── emi_calculator/               # EMI calculator tabs
│       ├── basic_emi_tab.dart
│       ├── amortization_schedule_tab.dart
│       ├── prepayment_analysis_tab.dart
│       ├── reverse_calculation_tab.dart
│       ├── loan_eligibility_tab.dart
│       └── loan_comparison_tab.dart
├── cards/
│   ├── tool_card.dart                # Dashboard tool cards
│   ├── qr_generator/                 # QR result cards
│   ├── barcode_generator/            # Barcode result cards
│   ├── age_calculator/               # Age result cards
│   ├── unit_converter/               # Converter cards
│   └── emi_calculator/               # EMI result cards
├── models/
│   ├── qr_generator_model.dart       # QR data models
│   ├── barcode_model.dart            # Barcode data models
│   ├── age_calculator_model.dart     # Age data models
│   ├── unit_converter_model.dart     # Unit data models
│   └── emi_calculator_model.dart     # EMI data models (Request/Response)
├── notifiers/
│   ├── qr_generator_notifier.dart    # QR state logic
│   ├── barcode_generator_notifier.dart
│   ├── age_calculator_notifier.dart
│   ├── unit_converter_notifier.dart
│   └── emi_calculator_notifier.dart
├── providers/
│   ├── qr_generator_provider.dart    # QR Riverpod providers
│   ├── barcode_generator_provider.dart
│   ├── age_calculator_provider.dart
│   ├── unit_converter_provider.dart
│   └── emi_calculator_provider.dart
├── api_services/
│   ├── api_routes.dart               # API endpoint constants
│   └── services/
│       ├── age_services.dart         # Age API client
│       ├── barcode_services.dart     # Barcode API client
│       ├── unit_converter_services.dart
│       └── emi_converter_services.dart
└── theme/
    └── app_theme.dart                # App-wide theming
```

---

## 🏗️ Architecture

### Design Patterns

1. **MVVM (Model-View-ViewModel)**
   - Models: Data structures and API contracts
   - Views: Screens and widgets
   - ViewModels: Notifiers managing state

2. **Provider Pattern**
   - Riverpod providers for dependency injection
   - Scoped state management
   - Automatic disposal

3. **Repository Pattern**
   - API services act as data repositories
   - Abstraction between UI and backend
   - Centralized API communication

---

## 📊 Architecture Diagrams

### 1. **High-Level System Architecture**

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER BROWSER                              │
│                    (Chrome/Firefox/Safari)                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTP/HTTPS
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   FLUTTER WEB APPLICATION                        │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    PRESENTATION LAYER                      │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │  │
│  │  │Dashboard │  │QR Gen    │  │Barcode   │  │Age Calc  │  │  │
│  │  │Screen    │  │Screen    │  │Screen    │  │Screen    │  │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │  │
│  │  ┌──────────┐  ┌──────────────────────────────────────┐  │  │
│  │  │Unit Conv │  │EMI Calculator (6 Tabs)               │  │  │
│  │  │Screen    │  │ - Basic | Amortization | Prepayment  │  │  │
│  │  └──────────┘  │ - Reverse | Eligibility | Compare    │  │  │
│  │                └──────────────────────────────────────┘  │  │
│  └─────────────────────────┬─────────────────────────────────┘  │
│                            │                                     │
│  ┌─────────────────────────▼─────────────────────────────────┐  │
│  │                   STATE MANAGEMENT LAYER                   │  │
│  │                     (Riverpod)                             │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │  │
│  │  │ Providers    │→ │ Notifiers    │→ │ State        │    │  │
│  │  │ (DI)         │  │ (Logic)      │  │ (Data)       │    │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │  │
│  └─────────────────────────┬─────────────────────────────────┘  │
│                            │                                     │
│  ┌─────────────────────────▼─────────────────────────────────┐  │
│  │                   DATA ACCESS LAYER                        │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │  │
│  │  │ API Services │  │ Models       │  │ Routes       │    │  │
│  │  │ (HTTP)       │  │ (DTO)        │  │ (Navigation) │    │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │  │
│  └─────────────────────────┬─────────────────────────────────┘  │
└────────────────────────────┼────────────────────────────────────┘
                             │
                             │ REST API (JSON)
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    FASTAPI BACKEND SERVER                        │
│                   (http://127.0.0.1:8000)                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Routes: /api/v1/{qr,barcode,age,converter,emi}/*      │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

### 2. **MVVM Architecture Pattern**

```
┌───────────────────────────────────────────────────────────────┐
│                         VIEW LAYER                             │
│  (Screens & Widgets - What user sees and interacts with)      │
│                                                                │
│  ┌─────────────────────┐  ┌─────────────────────┐            │
│  │ EmiCalculatorScreen │  │ AgeCalculatorScreen │            │
│  │                     │  │                     │            │
│  │ - Build UI          │  │ - Build UI          │            │
│  │ - Handle user input │  │ - Display results   │            │
│  │ - Display state     │  │ - Show errors       │            │
│  └──────────┬──────────┘  └──────────┬──────────┘            │
│             │                        │                        │
│             │ ConsumerWidget         │ ref.watch()            │
│             │ ref.watch() &          │ ref.read()             │
│             │ ref.read()             │                        │
└─────────────┼────────────────────────┼────────────────────────┘
              │                        │
              ▼                        ▼
┌───────────────────────────────────────────────────────────────┐
│                    VIEWMODEL LAYER                             │
│  (Notifiers - Business logic and state management)            │
│                                                                │
│  ┌───────────────────────────────────────────────────────┐    │
│  │ EmiCalculatorNotifier extends StateNotifier           │    │
│  │                                                        │    │
│  │ State: { loanAmount, rate, tenure, result, loading }  │    │
│  │                                                        │    │
│  │ Methods:                                               │    │
│  │  - updateLoanAmount(value)  → state.copyWith()       │    │
│  │  - updateRate(value)        → state.copyWith()       │    │
│  │  - calculateEMI()           → call service + update  │    │
│  │                                                        │    │
│  │ ┌──────────────────────────────────────────┐        │    │
│  │ │ state = state.copyWith(                  │        │    │
│  │ │   result: newResult,                     │        │    │
│  │ │   isLoading: false                       │        │    │
│  │ │ )  // Immutable state update             │        │    │
│  │ └──────────────────────────────────────────┘        │    │
│  └────────────────────┬──────────────────────────────────┘    │
│                       │                                        │
│                       │ Uses                                   │
│                       ▼                                        │
│  ┌───────────────────────────────────────────────────────┐    │
│  │ EmiConverterServices (Repository)                     │    │
│  │                                                        │    │
│  │ - calculateEMI() → HTTP POST to backend              │    │
│  │ - getAmortization() → HTTP GET                        │    │
│  │ - Error handling & retries                            │    │
│  └────────────────────┬──────────────────────────────────┘    │
└───────────────────────┼────────────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────────┐
│                      MODEL LAYER                               │
│  (Data structures and JSON serialization)                     │
│                                                                │
│  ┌───────────────────────────────────────────────────────┐    │
│  │ class EmiCalculationResult {                          │    │
│  │   final double emi;                                   │    │
│  │   final double totalAmount;                           │    │
│  │   final double totalInterest;                         │    │
│  │                                                        │    │
│  │   factory EmiCalculationResult.fromJson(json) {...}  │    │
│  │   Map<String, dynamic> toJson() {...}                │    │
│  │ }                                                      │    │
│  └───────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────┘
```

---

### 3. **Riverpod State Management Flow**

```
┌─────────────────────────────────────────────────────────────────┐
│                         main.dart                                │
│                                                                  │
│  void main() {                                                   │
│    runApp(                                                       │
│      ProviderScope(  ← Wraps entire app                         │
│        child: DailyUtilityToolsApp()                            │
│      )                                                           │
│    );                                                            │
│  }                                                               │
└──────────────────────────┬───────────────────────────────────────┘
                           │ Enables Riverpod
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PROVIDER LAYER                                │
│                  (Dependency Injection)                          │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐     │
│  │ // File: providers/emi_calculator_provider.dart       │     │
│  │                                                        │     │
│  │ // 1. Create Service Provider                         │     │
│  │ final emiServiceProvider = Provider<EmiService>((ref) {     │
│  │   return EmiConverterServices();                      │     │
│  │ });                                                    │     │
│  │                                                        │     │
│  │ // 2. Create State Provider (with dependency)         │     │
│  │ final emiCalculatorProvider =                         │     │
│  │   StateNotifierProvider<                              │     │
│  │     EmiCalculatorNotifier,                            │     │
│  │     EmiCalculatorState                                │     │
│  │   >((ref) {                                           │     │
│  │     final service = ref.watch(emiServiceProvider);    │     │
│  │     return EmiCalculatorNotifier(service);  ← Inject  │     │
│  │   });                                                  │     │
│  └────────────────────────────────────────────────────────┘     │
└──────────────────────────┬───────────────────────────────────────┘
                           │ Creates
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    NOTIFIER LAYER                                │
│                   (State + Business Logic)                       │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐     │
│  │ class EmiCalculatorNotifier                            │     │
│  │       extends StateNotifier<EmiCalculatorState> {      │     │
│  │                                                        │     │
│  │   final EmiConverterServices _service;  ← Injected    │     │
│  │                                                        │     │
│  │   // Constructor with initial state                   │     │
│  │   EmiCalculatorNotifier(this._service)                │     │
│  │     : super(EmiCalculatorState.initial());            │     │
│  │                                                        │     │
│  │   // Update methods                                   │     │
│  │   void updateLoanAmount(double amount) {              │     │
│  │     state = state.copyWith(loanAmount: amount);       │     │
│  │   }                                                    │     │
│  │                                                        │     │
│  │   // Business logic                                   │     │
│  │   Future<void> calculateEMI() async {                 │     │
│  │     state = state.copyWith(isLoading: true);          │     │
│  │     try {                                             │     │
│  │       final result = await _service.calculateEMI(...);│     │
│  │       state = state.copyWith(                         │     │
│  │         result: result,                               │     │
│  │         isLoading: false                              │     │
│  │       );                                              │     │
│  │     } catch (e) {                                     │     │
│  │       state = state.copyWith(error: e.toString());    │     │
│  │     }                                                  │     │
│  │   }                                                    │     │
│  │ }                                                      │     │
│  └────────────────────────────────────────────────────────┘     │
└──────────────────────────┬───────────────────────────────────────┘
                           │ Notifies
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                      UI LAYER                                    │
│                   (ConsumerWidget)                               │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐     │
│  │ class EmiCalculatorScreen                              │     │
│  │       extends ConsumerWidget {                         │     │
│  │                                                        │     │
│  │   @override                                           │     │
│  │   Widget build(BuildContext context, WidgetRef ref) { │     │
│  │     // WATCH state (rebuilds on change)               │     │
│  │     final state = ref.watch(emiCalculatorProvider);   │     │
│  │                                                        │     │
│  │     // READ notifier (call methods)                   │     │
│  │     final notifier =                                  │     │
│  │       ref.read(emiCalculatorProvider.notifier);       │     │
│  │                                                        │     │
│  │     return Column(                                    │     │
│  │       children: [                                     │     │
│  │         TextField(                                    │     │
│  │           onChanged: (value) {                        │     │
│  │             notifier.updateLoanAmount(                │     │
│  │               double.parse(value)                     │     │
│  │             );                                        │     │
│  │           }                                           │     │
│  │         ),                                            │     │
│  │         ElevatedButton(                               │     │
│  │           onPressed: () => notifier.calculateEMI(),   │     │
│  │           child: Text('Calculate')                    │     │
│  │         ),                                            │     │
│  │         if (state.isLoading)                          │     │
│  │           CircularProgressIndicator(),                │     │
│  │         if (state.result != null)                     │     │
│  │           Text('EMI: ${state.result!.emi}')           │     │
│  │       ]                                               │     │
│  │     );                                                │     │
│  │   }                                                    │     │
│  │ }                                                      │     │
│  └────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
```

---

### 4. **Complete Data Flow - EMI Calculation Example**

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: User enters loan amount in TextField                    │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 2: onChanged callback fires                                │
│   TextField.onChanged: (value) {                                │
│     ref.read(emiCalculatorProvider.notifier)                    │
│        .updateLoanAmount(double.parse(value));                  │
│   }                                                              │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: Notifier updates state                                  │
│   void updateLoanAmount(double amount) {                        │
│     state = state.copyWith(loanAmount: amount);                 │
│   }                                                              │
│   → StateNotifier notifies all listeners                        │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 4: UI automatically rebuilds                               │
│   final state = ref.watch(emiCalculatorProvider);               │
│   → All widgets watching this provider rebuild                  │
│   → TextField shows updated value                               │
└─────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────┐
│ STEP 5: User clicks "Calculate EMI" button                      │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 6: Button calls notifier method                            │
│   ElevatedButton(                                               │
│     onPressed: () {                                             │
│       ref.read(emiCalculatorProvider.notifier).calculateEMI();  │
│     }                                                            │
│   )                                                              │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 7: Notifier sets loading state                             │
│   state = state.copyWith(isLoading: true, error: null);         │
│   → UI rebuilds, shows CircularProgressIndicator                │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 8: Notifier calls API service                              │
│   final result = await _service.calculateEMI(                   │
│     loanAmount: state.loanAmount,                               │
│     annualRate: state.annualRate,                               │
│     tenure: state.tenure                                        │
│   );                                                             │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 9: Service makes HTTP request                              │
│   final response = await _dio.post(                             │
│     'http://127.0.0.1:8000/api/v1/emi/calculate',              │
│     data: {                                                      │
│       'loan_amount': 100000,                                    │
│       'annual_rate': 10,                                        │
│       'tenure_months': 12                                       │
│     }                                                            │
│   );                                                             │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 10: Backend processes request                              │
│   FastAPI Backend:                                              │
│   - Validates input                                             │
│   - Calculates EMI using financial formula                      │
│   - Returns JSON response                                       │
│                                                                  │
│   Response: {                                                    │
│     "success": true,                                            │
│     "data": {                                                    │
│       "emi": 8791.59,                                           │
│       "total_amount": 105499.08,                                │
│       "total_interest": 5499.08                                 │
│     }                                                            │
│   }                                                              │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 11: Service parses JSON response                           │
│   return EmiCalculationResult.fromJson(                         │
│     response.data['data']                                       │
│   );                                                             │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 12: Notifier updates state with result                     │
│   state = state.copyWith(                                       │
│     result: result,                                             │
│     isLoading: false                                            │
│   );                                                             │
│   → StateNotifier notifies all listeners                        │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 13: UI rebuilds with result                                │
│   if (state.isLoading)                                          │
│     return CircularProgressIndicator();  // Hidden              │
│   else if (state.result != null)                                │
│     return Column(                       // Shown ✓            │
│       children: [                                               │
│         Text('Monthly EMI: ₹${state.result!.emi}'),            │
│         Text('Total Interest: ₹${state.result!.totalInterest}')│
│         PieChart(...) // Visual breakdown                       │
│       ]                                                          │
│     );                                                           │
└─────────────────────────────────────────────────────────────────┘

Total time: ~200-500ms from button click to result display
```

---

### 5. **Folder-to-Layer Mapping**

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROJECT STRUCTURE                             │
│                  (How folders map to layers)                     │
└─────────────────────────────────────────────────────────────────┘

PRESENTATION LAYER (UI)
├── lib/screens/                      ← Main screens
│   ├── dashboard_screen.dart
│   ├── qr_generator_screen.dart
│   ├── barcode_generator_screen.dart
│   ├── age_calculator_screen.dart
│   ├── unit_converter_screen.dart
│   └── emi_calculator_screen_new.dart
│
├── lib/widgets/                      ← Reusable UI components
│   ├── app_shell.dart
│   ├── emi_calculator/
│   │   ├── basic_emi_tab.dart
│   │   ├── amortization_schedule_tab.dart
│   │   └── ... (4 more tabs)
│   ├── age_calculator/
│   └── ... (other feature widgets)
│
└── lib/cards/                        ← Result display cards
    ├── emi_calculator/
    │   ├── emi_breakdown_card.dart
    │   └── emi_value_card.dart
    └── ... (other feature cards)

                ↕ ref.watch() / ref.read()

STATE MANAGEMENT LAYER (Riverpod)
├── lib/providers/                    ← Dependency injection
│   ├── emi_calculator_provider.dart
│   ├── age_calculator_provider.dart
│   └── ... (other providers)
│
└── lib/notifiers/                    ← Business logic
    ├── emi_calculator_notifier.dart
    ├── age_calculator_notifier.dart
    └── ... (other notifiers)

                ↕ Service calls

DATA ACCESS LAYER (Repository)
├── lib/api_services/
│   ├── api_routes.dart              ← API endpoints
│   └── services/
│       ├── emi_converter_services.dart
│       ├── age_services.dart
│       └── ... (other services)
│
└── lib/models/                       ← Data models (DTO)
    ├── emi_calculator_model.dart
    ├── age_calculator_model.dart
    └── ... (other models)

                ↕ HTTP requests

NAVIGATION & THEMING
├── lib/routes/                       ← App navigation
│   ├── app_router.dart
│   └── app_pages.dart
│
└── lib/theme/                        ← Styling
    └── app_theme.dart
```

---

### 6. **Feature Communication Pattern**

```
┌─────────────────────────────────────────────────────────────────┐
│              HOW FEATURES ARE ISOLATED YET CONNECTED             │
└─────────────────────────────────────────────────────────────────┘

Feature 1: EMI Calculator
┌──────────────────────────────────────────┐
│ emi_calculator_screen_new.dart           │
│         ↕ ref.watch/read                 │
│ emi_calculator_provider.dart             │
│         ↕ creates                        │
│ emi_calculator_notifier.dart             │
│         ↕ uses                           │
│ emi_converter_services.dart              │
│         ↕ JSON                           │
│ emi_calculator_model.dart                │
└──────────────────────────────────────────┘
                │
                │ Shares only: Theme, Routes, HTTP Client
                │
Feature 2: Age Calculator
┌──────────────────────────────────────────┐
│ age_calculator_screen.dart               │
│         ↕ ref.watch/read                 │
│ age_calculator_provider.dart             │
│         ↕ creates                        │
│ age_calculator_notifier.dart             │
│         ↕ uses                           │
│ age_services.dart                        │
│         ↕ JSON                           │
│ age_calculator_model.dart                │
└──────────────────────────────────────────┘

SHARED INFRASTRUCTURE:
- AppTheme (styling)
- GoRouter (navigation)
- Dio (HTTP client)
- ProviderScope (state management container)

BENEFITS:
✓ Features don't depend on each other
✓ Easy to add/remove features
✓ Can be developed in parallel
✓ Clear boundaries
```

---

### State Management Flow

```
User Input → Notifier → API Service → Backend
                ↓
            Provider
                ↓
           UI Updates
```

### API Integration

- **Base URL**: `http://127.0.0.1:8000` (configurable in `api_routes.dart`)
- **HTTP Client**: Dio with logging interceptor
- **Error Handling**: Try-catch with user-friendly messages
- **Request/Response**: Strongly typed models with JSON serialization

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (Channel stable, ^3.10.4)
- **Dart SDK** (^3.10.4)
- **Chrome** or another supported web browser
- **Backend Server** running on `http://127.0.0.1:8000`

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Daily_Utility_tools_frontend/Frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify installation**
   ```bash
   flutter doctor
   ```

### Running the Application

#### Development Mode (with hot reload)
```bash
flutter run -d chrome
```

#### Specific port
```bash
flutter run -d web-server --web-port=8080
```

#### Release mode
```bash
flutter run -d chrome --release
```

### Building for Production

```bash
# Build optimized web bundle
flutter build web

# Output will be in: build/web/
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
flutter format lib/
```

---

## 🔧 Configuration

### Backend API URL

Update the base URL in `lib/api_services/api_routes.dart`:

```dart
const String apiBaseUrl = 'http://127.0.0.1:8000';
```

### Theme Customization

Modify theme settings in `lib/theme/app_theme.dart`:

```dart
static const Color primary = Color(0xFF6C5CE7);
static const Color secondary = Color(0xFFFD79A8);
static const Color accent = Color(0xFFFDCB6E);
// ... more theme properties
```

---

## 📱 Screens Overview

### Dashboard
- Hero section with app branding
- Tool cards for quick access
- Responsive grid layout
- Smooth hover animations

### QR Generator
- Text/URL input field
- Size selection (Small, Medium, Large)
- Live QR preview
- Download & copy functionality

### Barcode Generator
- Input text field
- 11 barcode type options
- Base64 image preview
- Download capability

### Age Calculator
- Date picker for birth date
- Timezone dropdown
- Comprehensive age analytics
- Planetary age calculations
- Famous birthdays section

### Unit Converter
- Category selection
- From/To unit dropdowns
- Real-time conversion
- Swap button for quick reversal

### EMI Calculator
- Tabbed interface with 6 features
- Independent state per tab
- Visual charts and breakdowns
- Downloadable reports

---

## 🎨 UI/UX Features

- **Responsive Design** - Works on desktop, tablet, and mobile
- **Dark Theme** - Modern dark UI with gradient accents
- **Smooth Animations** - Fade, slide, and scale effects
- **Loading States** - Skeleton loaders and spinners
- **Error Handling** - User-friendly error messages
- **Input Validation** - Real-time validation feedback
- **Accessibility** - Semantic markup and ARIA labels

---

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/models/emi_calculator_model_test.dart
```

Run with coverage:
```bash
flutter test --coverage
```

---

## 📦 Dependencies Management

### Adding a new dependency
```bash
flutter pub add package_name
```

### Updating dependencies
```bash
flutter pub upgrade
```

### Checking outdated packages
```bash
flutter pub outdated
```

---

## 🐛 Troubleshooting

### Hot Reload Not Working
```bash
# Kill Chrome and restart
flutter clean
flutter pub get
flutter run -d chrome
```

### Build Errors
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### API Connection Issues
- Ensure backend is running on `http://127.0.0.1:8000`
- Check `api_routes.dart` for correct endpoint URLs
- Enable CORS in backend if needed

---

## 🔮 Future Enhancements

### Planned Features
- PDF report generation for EMI calculations
- Loan comparison export to CSV
- Dark/Light theme toggle
- Multi-language support
- Offline mode with cached data
- User authentication and saved calculations
- Mobile app versions (iOS/Android)

### Technical Improvements
- Unit test coverage to 80%+
- Integration tests
- Performance optimization
- PWA support
- Web workers for heavy calculations

---

## 📄 License

This project is currently private and unpublished.

---

## 👥 Contributing

This is an internship project. For contribution guidelines, please contact the project maintainers.

---

## 📞 Support

For issues and questions:
- Check the THEME_GUIDE.md for UI/design guidelines
- Review API documentation in backend README
- Contact: [Project Maintainer]

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- Backend team for robust API services
- Design inspiration from modern fintech apps

---

**Built with ❤️ using Flutter**
