import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../services/hive_service.dart';
import '../services/permission_service.dart';
import '../utils/app_theme.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    final granted = await PermissionService.requestAllPermissions();
    if (granted) {
      await HiveService.setOnboardingCompleted(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: 'Permissions Required',
        desc: 'Camera and storage permissions are required for the app to work properly.',
        btnOkText: 'Try Again',
        btnOkOnPress: () => _requestPermissions(),
        btnCancelText: 'Skip',
        btnCancelOnPress: () async {
          await HiveService.setOnboardingCompleted(true);
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        },
      ).show();
    }
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
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildWelcomePage(isDark),
                    _buildFeaturesPage(isDark),
                    _buildPermissionsPage(isDark),
                  ],
                ),
              ),
              _buildPageIndicator(isDark),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFFFFFFFF),
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        _currentPage == 2 ? 'Allow & Continue' : 'Next',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
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
            child: Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'All-in-One Scanner',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF212121),
              shadows: [
                Shadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scan anything instantly',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage(bool isDark) {
    final features = [
      {'icon': Icons.qr_code, 'title': 'QR Scanner', 'desc': 'Scan QR codes instantly'},
      {'icon': Icons.qr_code_2, 'title': 'Barcode Scanner', 'desc': 'Detect all barcode types'},
      {'icon': Icons.create, 'title': 'QR/Barcode Generator', 'desc': 'Create your own codes'},
      {'icon': Icons.history, 'title': 'History Tracking', 'desc': 'Keep track of all scans'},
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Features',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF212121),
              shadows: [
                Shadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isDark
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFFFFFFF),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(
                        feature['icon'] as IconData,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                      title: Text(
                        feature['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        feature['desc'] as String,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsPage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
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
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.security,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Permissions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We need camera and storage permissions to scan codes and save your history.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Container(
            width: _currentPage == index ? 24 : 12,
            height: 12,
            decoration: BoxDecoration(
              shape: _currentPage == index
                  ? BoxShape.rectangle
                  : BoxShape.circle,
              borderRadius: _currentPage == index
                  ? BorderRadius.circular(6)
                  : null,
              color: _currentPage == index
                  ? AppTheme.primaryColor
                  : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFFFFFF)),
              boxShadow: [
                BoxShadow(
                  color: (_currentPage == index
                          ? AppTheme.primaryColor
                          : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFFFFFF)))
                      .withOpacity(0.3),
                  blurRadius: _currentPage == index ? 8 : 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}


