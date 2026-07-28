import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';
import '../providers/auth_provider.dart';
import 'main_navigation.dart';
import 'profile/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    Widget nextScreen;
    if (auth.isAuthenticated) {
      nextScreen = const MainNavigation();
    } else {
      nextScreen = const LoginScreen(redirectToCheckout: false);
    }
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Luxury logo
              Text(
                'vamika',
                style: AppTextStyles.serifHeading1(color: AppColors.charcoal).copyWith(
                  fontSize: 44,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '&',
                style: AppTextStyles.serifBody(color: AppColors.gold, fontSize: 32).copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'bhargavi',
                style: AppTextStyles.serifHeading1(color: AppColors.charcoal).copyWith(
                  fontSize: 44,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 40,
                height: 1,
                color: AppColors.gold.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'HANDCRAFTED LUXURY WEAR',
                style: AppTextStyles.uppercaseLabel(
                  color: AppColors.stone,
                  fontSize: 9,
                  letterSpacing: 3.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
