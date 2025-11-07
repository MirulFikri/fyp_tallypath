# TallyPath - Personal Finance Tracker

A comprehensive Flutter mobile application for tracking expenses, managing budgets, and achieving financial goals.

## Features

### 🔐 Authentication
- **Login Screen**: User authentication with email and password
- **Sign Up Screen**: New user registration with validation
- **Password visibility toggle**
- **Form validation**

### 📊 Dashboard
- **Balance Overview**: Display total balance, income, and expenses
- **Quick Actions**: Quick add income/expense buttons
- **Spending Overview**: Visual breakdown by category with progress bars
- **Recent Transactions**: Latest transactions preview
- **Floating Action Button**: Quick access to add transactions

### 💰 Transactions
- **Transaction List**: Complete history of all transactions
- **Filters**: Filter by All, Income, or Expense
- **Transaction Details**: Modal with full transaction information
- **Add Transaction**: Form to add new income/expense with:
  - Type selection (Income/Expense)
  - Amount input
  - Category dropdown
  - Description
  - Date picker
- **Edit/Delete**: Manage existing transactions

### 📈 Budget Management
- **Monthly Budget Overview**: Total budget with progress indicator
- **Category Budgets**: Individual budget tracking for:
  - Food & Dining
  - Transportation
  - Shopping
  - Entertainment
  - Bills & Utilities
  - Healthcare
- **Visual Progress**: Progress bars showing spending vs budget
- **Budget Alerts**: Visual warnings when approaching budget limits
- **Add/Edit Budget**: Manage budget allocations

### 👤 Profile
- **User Information**: Display user details
- **Statistics Cards**: Quick view of balance and monthly trends
- **Account Settings**:
  - Personal Information
  - Payment Methods
  - Notification toggle
- **Preferences**:
  - Theme selection
  - Language
  - Currency
- **Support**:
  - Help & Support
  - Privacy Policy
  - Terms of Service
  - About/Version info
- **Logout**: Secure logout functionality

## UI/UX Design

### Color Scheme
- **Primary Color**: Green (#4CAF50) - representing financial growth
- **Background**: Light green tint (#F1FFF3) - easy on the eyes
- **Accent Colors**:
  - Orange: Food & Dining
  - Blue: Transportation
  - Purple: Shopping
  - Pink: Entertainment
  - Amber: Bills & Utilities
  - Red: Healthcare

### Navigation
- **Bottom Navigation Bar** with 4 tabs:
  - Dashboard
  - Transactions
  - Budget
  - Profile

### Components
- **Cards**: Elevated cards with rounded corners (12px radius)
- **Buttons**: Material design with consistent padding
- **Progress Indicators**: Linear progress bars with color-coded alerts
- **Icons**: Material icons throughout for visual consistency
- **Modal Sheets**: Bottom sheets for detailed views

## Project Structure

```
lib/
├── main.dart                          # App entry point
└── screens/
    ├── login_screen.dart              # User login
    ├── signup_screen.dart             # User registration
    ├── home_screen.dart               # Main navigation container
    ├── dashboard_screen.dart          # Dashboard with overview
    ├── transactions_screen.dart       # Transaction list & management
    ├── add_transaction_screen.dart    # Add/Edit transaction form
    ├── budget_screen.dart             # Budget management
    └── profile_screen.dart            # User profile & settings
```

## Features Implemented

✅ Multi-screen navigation with bottom navigation bar
✅ Form validation for all input fields
✅ Date picker for transaction dates
✅ Category-based organization
✅ Progress tracking for budgets
✅ Modal bottom sheets for details
✅ Responsive cards and layouts
✅ Color-coded categories
✅ Filter functionality
✅ Quick action buttons
✅ Statistics display
✅ Settings management

## Getting Started

### Prerequisites
- Flutter SDK (^3.7.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
2. Navigate to the project directory
```bash
cd fyp_tallypath
```

3. Install dependencies
```bash
flutter pub get
```

4. Run the app
```bash
# For Android
flutter run

# For iOS
flutter run

# For Windows
flutter run -d windows

# For Web
flutter run -d chrome
```

## Next Steps (Backend Integration)

To make this app fully functional, you'll need to:

1. **Database Integration**
   - Set up Firebase/Supabase or local database (SQLite)
   - Create data models
   - Implement CRUD operations

2. **Authentication**
   - Connect to Firebase Auth or custom backend
   - Implement secure login/signup
   - Add password reset functionality

3. **State Management**
   - Implement Provider/Riverpod/Bloc for state management
   - Handle real-time data updates

4. **Data Persistence**
   - Save user preferences
   - Cache transaction data
   - Implement offline support

5. **Analytics**
   - Add charts and graphs (fl_chart package)
   - Implement spending analytics
   - Create financial reports

6. **Notifications**
   - Budget limit alerts
   - Bill payment reminders
   - Daily/weekly summaries

## Technologies Used

- **Framework**: Flutter 3.7.0
- **Language**: Dart
- **UI**: Material Design 3
- **Icons**: Material Icons

## Design Principles

- **Material Design 3** guidelines
- **Responsive layouts** for different screen sizes
- **Intuitive navigation** with clear visual hierarchy
- **Consistent color scheme** for easy recognition
- **Accessibility** considerations with proper contrast ratios

## License

This project is created for educational purposes as part of a Final Year Project.

---

**Note**: This is a frontend implementation. All data is currently static and stored in memory. Backend integration is required for production use.
