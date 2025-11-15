import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
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
    await HiveService.init();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final isOnboardingCompleted = HiveService.isOnboardingCompleted();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isOnboardingCompleted
            ? const MainScreen()
            : const OnboardingScreen(),
      ),
    );
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
      body: NeumorphicBackground(
        child: Container(
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
                    // Neumorphic circle with logo
                    Neumorphic(
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.convex,
                        boxShape: NeumorphicBoxShape.circle(),
                        depth: 20,
                        intensity: 0.8,
                        lightSource: LightSource.topLeft,
                        color: isDark
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFFFFFFFF),
                      ),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SpinKitSpinningLines(
                            color: AppTheme.primaryColor,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Fade in text
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: NeumorphicText(
                        'Scanning Simplified',
                        style: NeumorphicStyle(
                          depth: 4,
                          color: isDark
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFF212121),
                        ),
                        textStyle: NeumorphicTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper class for Neumorphic background
class NeumorphicBackground extends StatelessWidget {
  final Widget child;

  const NeumorphicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

// Helper class for Neumorphic text
class NeumorphicText extends StatelessWidget {
  final String text;
  final NeumorphicStyle style;
  final NeumorphicTextStyle textStyle;

  const NeumorphicText(
    this.text, {
    super.key,
    required this.style,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: style,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: textStyle.fontSize,
            fontWeight: textStyle.fontWeight,
            letterSpacing: textStyle.letterSpacing,
            color: style.color,
          ),
        ),
      ),
    );
  }
}

// NeumorphicTextStyle helper
class NeumorphicTextStyle {
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;

  const NeumorphicTextStyle({
    required this.fontSize,
    required this.fontWeight,
    this.letterSpacing = 0,
  });
}


