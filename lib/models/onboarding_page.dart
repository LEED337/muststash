class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;
  final String? animationPath;
  final List<String> features;
  final String primaryButtonText;
  final String? secondaryButtonText;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    this.animationPath,
    required this.features,
    required this.primaryButtonText,
    this.secondaryButtonText,
  });
}

class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: "Welcome to MustStash",
      subtitle: "Your Smart Savings Companion",
      description: "Turn your everyday purchases into savings with automatic spare change collection and smart financial insights.",
      imagePath: "assets/images/onboarding_welcome.png",
      features: [],
      primaryButtonText: "Get Started",
      secondaryButtonText: "Skip",
    ),
    OnboardingPage(
      title: "Round Up & Save",
      subtitle: "Every Purchase Counts",
      description: "We automatically round up your purchases to the nearest dollar and save the spare change for you.",
      imagePath: "assets/images/onboarding_roundup.png",
      features: [],
      primaryButtonText: "Continue",
    ),
    OnboardingPage(
      title: "Set Your Goals",
      subtitle: "Save for What Matters",
      description: "Create savings goals for things you want and watch your spare change help you achieve them faster.",
      imagePath: "assets/images/onboarding_goals.png",
      features: [],
      primaryButtonText: "Continue",
    ),
    OnboardingPage(
      title: "Connect Your Card or Bank",
      subtitle: "Secure & Automatic",
      description: "Safely connect your bank account for automatic transaction tracking and seamless savings.",
      imagePath: "assets/images/onboarding_bank.png",
      features: [],
      primaryButtonText: "Continue",
      secondaryButtonText: "Skip for Now",
    ),
    OnboardingPage(
      title: "Smart Price Tracking",
      subtitle: "Never Miss a Deal",
      description: "Track prices on your wishlist items and get notified when they go on sale.",
      imagePath: "assets/images/onboarding_prices.png",
      features: [],
      primaryButtonText: "Continue",
    ),
  ];
}