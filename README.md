# 💰 MustStash - Spare Change Savings App

MustStash helps people save for their wishlist items by automatically rounding up purchases and collecting spare change, similar to apps like Acorns.

## 🚀 **Live Demo**
**👉 [Try MustStash Now!](https://leed337.github.io/muststash/)**

*The app is now live and ready to explore!*

## 🎯 MVP Features

- **Onboarding Flow**: Welcome users and collect basic information
- **Coin Jar**: Track spare change savings with mock transaction data
- **Wish Stash**: Manage wishlist items with priority ordering
- **Progress Tracking**: Gamified progress bars showing savings goals
- **Responsive Design**: Works on web, iOS, and Android

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   # Web
   flutter run -d chrome
   
   # iOS Simulator
   flutter run -d ios
   
   # Android Emulator
   flutter run -d android
   ```

## 📱 App Structure

### Screens
- **Splash Screen**: App loading and routing logic
- **Onboarding**: Multi-step user introduction
- **Home**: Dashboard with savings overview and quick actions
- **Coin Jar**: Transaction history and savings details
- **Wish Stash**: Wishlist management with progress tracking
- **Add Wish**: Form to add new wishlist items

### State Management
- **Provider Pattern**: Used for state management
- **Local Storage**: SharedPreferences for data persistence
- **Mock Data**: Simulated transactions and sample wishes for demo

## 🎨 Design System

### Modern UI Features
- **Beautiful Gradients**: Green and gold gradient themes throughout the app
- **Glass-morphism Effects**: Semi-transparent overlays with blur effects
- **Card-Based Design**: Elevated surfaces with proper shadows and rounded corners
- **Animated Transitions**: Smooth animations between screens and states
- **Responsive Layout**: Adapts perfectly to different screen sizes
- **Custom Components**: Specially designed progress indicators and buttons

### Colors
- Primary Green: `#2E7D32`
- Light Green: `#4CAF50`
- Accent Gold: `#FFB300`
- Background Light: `#F8F9FA`
- Gradient Combinations:
  - Primary Gradient: Green tones from dark to light
  - Gold Gradient: Gold to amber for accent elements

### Typography
- Google Fonts (Inter) for clean, modern text
- Consistent sizing and weight hierarchy
- Enhanced text contrast for better readability
- Proper spacing between text elements

## 🔮 Future Features (Post-MVP)

### Phase 2: Payment Integration
- Real bank account connections
- Actual transaction processing
- Secure payment handling

### Phase 3: Advanced Features
- Price comparison API integration
- Affiliate marketing partnerships
- Advanced analytics and insights
- Social features and sharing

### Phase 4: Monetization
- Premium subscriptions ($5/month)
- Ad integration for free users
- Interest from stored funds
- Affiliate commission revenue

## 🏗️ Technical Architecture

### Frontend
- **Flutter**: Cross-platform mobile/web framework
- **Provider**: State management solution
- **Go Router**: Navigation and routing
- **SharedPreferences**: Local data storage

### Future Backend (Not in MVP)
- RESTful API for user data
- Bank integration APIs (Plaid, Yodlee)
- Price comparison services
- Payment processing (Stripe, PayPal)

## 📊 Business Model

### Revenue Streams
1. **Premium Subscriptions**: $5/month for ad-free experience
2. **Interest Income**: From user savings held in partner banks
3. **Affiliate Commissions**: From purchase redirections
4. **Advertising**: Display ads for free tier users

### Target Market
- Young adults (18-35) who struggle with saving
- Impulse buyers who want better financial habits
- Tech-savvy users comfortable with fintech apps

## 🧪 Testing the MVP

### Demo Data
The app includes mock data for demonstration:
- Sample transactions showing spare change collection
- Pre-populated wishlist items with different price points
- Simulated progress tracking

### Key User Flows to Test
1. Complete onboarding process
2. View savings dashboard and progress
3. Add new wishlist items
4. Navigate between different sections
5. Experience the gamification elements

## 📈 Next Steps for Investors/Customers

1. **User Testing**: Gather feedback on UI/UX and core concept
2. **Market Validation**: Confirm demand for spare change savings
3. **Technical Validation**: Prove feasibility of bank integrations
4. **Business Model Testing**: Validate pricing and revenue assumptions

## 🔒 Security Considerations (Future)

- Bank-level encryption for financial data
- PCI DSS compliance for payment processing
- Multi-factor authentication
- Regular security audits and penetration testing

## 📞 Contact

This MVP demonstrates the core concept and user experience of MustStash. For investment opportunities or partnership discussions, please reach out to discuss the full business plan and technical roadmap.

---

**Note**: This is an MVP with mock data. Real financial integrations and payment processing will be implemented in subsequent phases with proper security and compliance measures.