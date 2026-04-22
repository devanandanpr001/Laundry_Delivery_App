import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'dart:async';
import 'onBoardingScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<Offset> _iconSlide;
  late Animation<Offset> _textSlide;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    /// Icon from left
    _iconSlide = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    /// Text from right
    _textSlide = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    /// Shake effect (small horizontal vibration)
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Onboardingscreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// 🔹 Icon (from left)
                    SlideTransition(
                      position: _iconSlide,
                      child: Image.asset(
                        'assets/icons/laundry_logo.png',
                        width: 90,
                        color: AppColors.primaryBlue,
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// 🔹 Text (from right)
                    SlideTransition(
                      position: _textSlide,
                      child: Text(
                        'Juggle Laundry',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
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