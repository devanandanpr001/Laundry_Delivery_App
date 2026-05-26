import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/bottom_navigation_page.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Notification/data/Service/notification_service.dart';
import 'package:ziya_laundry_deliveryapp/core/services/AppUpdateService.dart';
import 'package:ziya_laundry_deliveryapp/core/services/token_service.dart';
import 'package:ziya_laundry_deliveryapp/onBoarding/onBoardingScreen.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_images.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Profile/viewmodel/profile_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/Notification/viewmodel/notification_viewmodel.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;

  // Phase 1: Icon drops in from top with scale + fade (0.0 → 0.4)
  late Animation<double> _iconFade;
  late Animation<double> _iconScale;
  late Animation<Offset> _iconSlide;

  // Phase 2: Text slides in from right with fade (0.3 → 0.6)
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  // Phase 3: Bounce pulse when both settle (0.55 → 0.75)
  late Animation<double> _bounceScale;

  // Continuous glow pulse around logo
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // ── Main choreography controller ──
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // ── Glow pulse controller (loops) ──
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // ═══════════════════════════════════════
    // Phase 1: Icon entrance (0.0 → 0.4)
    // ═══════════════════════════════════════
    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _iconScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _iconSlide = Tween<Offset>(
      begin: const Offset(0, -0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    // ═══════════════════════════════════════
    // Phase 2: Text entrance (0.3 → 0.6)
    // ═══════════════════════════════════════
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.55, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // ═══════════════════════════════════════
    // Phase 3: Bounce pulse (0.55 → 0.75)
    // ═══════════════════════════════════════
    _bounceScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 3),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.97), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.0), weight: 2),
    ]).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.75, curve: Curves.easeInOut),
      ),
    );

    // ═══════════════════════════════════════
    // Glow pulse (continuous loop)
    // ═══════════════════════════════════════
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Start animations
    _mainController.forward();

    // Start glow after main entrance finishes
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _glowController.repeat(reverse: true);
      }
    });

    _navigateToNext();
  }

Future<void> _navigateToNext() async {

  // Splash animation delay
  await Future.delayed(
    const Duration(seconds: 3),
  );

  if (!mounted) return;

  try {

    // Android Play Store update
    await AppUpdateService.checkAndroidUpdate();

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

  } catch (e) {

    debugPrint(
      "Update check failed: $e",
    );
  }

  final tokenService = TokenService();

  final token =
      await tokenService.getAccessToken();

  if (!mounted) return;

  // ============================
  // USER LOGGED IN
  // ============================
  if (token != null &&
      token.isNotEmpty) {

    try {

      /// FETCH PROFILE
      await context
          .read<ProfileViewModel>()
          .fetchProfileData();

      if (!mounted) return;

      /// INIT NOTIFICATIONS
      final profile =
          context
              .read<ProfileViewModel>()
              .userProfile;

      context
          .read<NotificationViewModel>()
          .init(
            profile?['id']?.toString() ?? '',
            profile?['role']?.toString() ?? '',
          );

      if (!mounted) return;

      /// ============================
      /// HANDLE TERMINATED NOTIFICATION
      /// ============================
      final notificationService =
          NotificationService.instance;

      if (notificationService
              .pendingNavigationData !=
          null) {

        final data =
            notificationService
                .pendingNavigationData!;

        notificationService
            .pendingNavigationData = null;

        /// OPEN HOME FIRST
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: '/home'),
            builder: (_) =>
                const BottomNavigationPage(),
          ),
        );

        /// WAIT UNTIL NAVIGATOR READY
        WidgetsBinding.instance
            .addPostFrameCallback((_) {

          notificationService
              .handlePendingNavigation(
            data,context,
          );
        });

        return;
      }

      /// NORMAL HOME NAVIGATION
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: '/home'),
          builder: (_) =>
              const BottomNavigationPage(),
        ),
      );

    } catch (e) {

      debugPrint(
        "Session verification failed: $e",
      );

      if (!mounted) return;

      final errorMsg =
          e.toString().toLowerCase();

      final bool isNetworkError =
          errorMsg.contains("socket") ||
          errorMsg.contains("connection") ||
          errorMsg.contains("internet") ||
          errorMsg.contains("network") ||
          errorMsg.contains("timeout");

      /// OFFLINE USER
      if (isNetworkError) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: '/home'),
            builder: (_) =>
                const BottomNavigationPage(),
          ),
        );
      }

      /// INVALID TOKEN
      else {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: '/onboarding'),
            builder: (_) =>
                const Onboardingscreen(),
          ),
        );
      }
    }
  }

  // ============================
  // USER NOT LOGGED IN
  // ============================
  else {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/onboarding'),
        builder: (_) =>
            const Onboardingscreen(),
      ),
    );
  }
}
  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_mainController, _glowController]),
            builder: (context, child) {
              return Transform.scale(
                  scale: _bounceScale.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// 🔹 Logo with glow ring
                      SlideTransition(
                        position: _iconSlide,
                        child: FadeTransition(
                          opacity: _iconFade,
                          child: Transform.scale(
                            scale: _iconScale.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withOpacity(
                                      0.25 * _glowAnimation.value,
                                    ),
                                    blurRadius: 30 + 20 * _glowAnimation.value,
                                    spreadRadius: 5 * _glowAnimation.value,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                AppImages.appLogo,
                                width: 90.w,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 2.h),

                      /// 🔹 Text with fade + slide from right
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textFade,
                          child: Text(
                            'Juggle Laundry',
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryBlue,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              );
            },
          ),
        ),
      ),
    );
  }
}