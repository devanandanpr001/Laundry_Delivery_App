import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';


class SuccessSplashScreen extends StatefulWidget {
  final String? message;
  final Duration autoCloseDuration;

  const SuccessSplashScreen({
    super.key,
    this.message,
    this.autoCloseDuration = const Duration(milliseconds: 2000),
  });

  static Future<void> show(
    BuildContext context, {
    String? message,
    Duration autoCloseDuration = const Duration(milliseconds: 2000),
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => SuccessSplashScreen(
          message: message,
          autoCloseDuration: autoCloseDuration,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  State<SuccessSplashScreen> createState() => _SuccessSplashScreenState();
}

class _SuccessSplashScreenState extends State<SuccessSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ).drive(Tween(begin: 0.85, end: 1.0));

    _controller.forward();
    _scheduleDismiss();
  }

  void _scheduleDismiss() {
    _dismissTimer = Timer(widget.autoCloseDuration, () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Premium dark background with slight blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 20,
                sigmaY: 20,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.45),
                ),
              ),
            ),
          ),
          
          // 2. Centered iOS / Material 3 Glassmorphism Popup
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _controller,
                child: Container(
                  width: 320.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    color: Colors.white.withOpacity(.12),
                    border: Border.all(
                      color: Colors.white.withOpacity(.18),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.15),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 20,
                        sigmaY: 20,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 30.h,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Success animation inside circular background
                            Container(
                              height: 120.h,
                              width: 120.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(.08),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.r),
                                child: Lottie.asset(
                                  "assets/gifs/successful.json",
                                  repeat: false,
                                ),
                              ),
                            ),

                            SizedBox(height: 22.h),

                            // Bold Title
                            Text(
                              "Success",
                              style: GoogleFonts.poppins(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),

                            SizedBox(height: 10.h),

                            // Subtitle
                            Text(
                              widget.message ??
                                  "Your request has been completed successfully.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                color: Colors.white70,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}