import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/hive_service.dart';
import '../utils/app_theme.dart';
import 'onboarding_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // HiveService is already initialized in main.dart, so we don't need to init again
      // Just wait for the splash animation
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;

      final isOnboardingCompleted = HiveService.isOnboardingCompleted();
      
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => isOnboardingCompleted
              ? const MainScreen()
              : const OnboardingScreen(),
        ),
      );
    } catch (e) {
      // If there's an error, still try to navigate to main screen
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2D2D2D),
                  ]
                : [
                    const Color(0xFFE0E0E0),
                    const Color(0xFFF5F5F5),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Lottie background animation
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: Lottie.asset(
                  'assets/lottie/particles.json',
                  fit: BoxFit.cover,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox();
                  },
                ),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circle with logo
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFFFFFFF),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(-5, -5),
                        ),
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SpinKitSpinningLines(
                        color: AppTheme.primaryColor,
                        size: 80,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Fade in text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Scanning Simplified',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                          color: isDark
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFF212121),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



