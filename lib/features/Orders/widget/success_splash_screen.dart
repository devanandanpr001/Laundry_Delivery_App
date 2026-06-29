// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';

// class SuccessSplashScreen extends StatefulWidget {
//   final String? message;
//   final Duration autoCloseDuration;

//   const SuccessSplashScreen({
//     super.key,
//     this.message,
//     this.autoCloseDuration = const Duration(milliseconds: 2000),
//   });

//   static Future<void> show(
//     BuildContext context, {
//     String? message,
//     Duration autoCloseDuration = const Duration(milliseconds: 2000),
//   }) {
//     return Navigator.of(context).push(
//       PageRouteBuilder(
//         fullscreenDialog: true,
//         opaque: false,
//         pageBuilder: (context, animation, secondaryAnimation) => SuccessSplashScreen(
//           message: message,
//           autoCloseDuration: autoCloseDuration,
//         ),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           return FadeTransition(opacity: animation, child: child);
//         },
//         transitionDuration: const Duration(milliseconds: 300),
//       ),
//     );
//   }

//   @override
//   State<SuccessSplashScreen> createState() => _SuccessSplashScreenState();
// }

// class _SuccessSplashScreenState extends State<SuccessSplashScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _scaleAnimation;
//   Timer? _dismissTimer;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );

//     _scaleAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutBack,
//     ).drive(Tween(begin: 0.85, end: 1.0));

//     _controller.forward();
//     _scheduleDismiss();
//   }

//   void _scheduleDismiss() {
//     _dismissTimer = Timer(widget.autoCloseDuration, () {
//       if (mounted) {
//         Navigator.of(context).pop();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _dismissTimer?.cancel();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Center(
//         child: ScaleTransition(
//           scale: _scaleAnimation,
//           child: FadeTransition(
//             opacity: _controller,
//             child: Container(
//               width: 320.w,
//               padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.15),
//                     blurRadius: 25,
//                     offset: const Offset(0, 12),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     height: 120.h,
//                     width: 120.w,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.grey.withValues(alpha: 0.08),
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.all(12.r),
//                       child: Lottie.asset(
//                         "assets/gifs/successful.json",
//                         repeat: false,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 22.h),
//                   Text(
//                     "Success",
//                     style: GoogleFonts.poppins(
//                       fontSize: 24.sp,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black,
//                     ),
//                   ),
//                   SizedBox(height: 10.h),
//                   Text(
//                     widget.message ??
//                         "Your request has been completed successfully.",
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.poppins(
//                       fontSize: 15.sp,
//                       color: Colors.grey[600],
//                       height: 1.5,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessSplashScreen extends StatefulWidget {
  final String? message;
  final Duration autoCloseDuration;

  const SuccessSplashScreen({
    super.key,
    this.message,
    this.autoCloseDuration = const Duration(milliseconds: 2500),
  });

  static Future<void> show(
    BuildContext context, {
    String? message,
    Duration autoCloseDuration = const Duration(milliseconds: 2500),
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) => SuccessSplashScreen(
          message: message,
          autoCloseDuration: autoCloseDuration,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
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
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ).drive(Tween(begin: 0.6, end: 1.0));

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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Confetti Background Layer
          Positioned.fill(
            child: CustomPaint(
              painter: ConfettiBackgroundPainter(),
            ),
          ),

          // 2. Main Content
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _controller,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Double Circle Success Checkmark
                      Container(
                        height: 180.w,
                        width: 180.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8F9E9), // Light mint ring
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          height: 110.w,
                          width: 110.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF22C55E), // Vibrant green core
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 65.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 45.h),

                      // Success Title / Message
                      Text(
                        widget.message ?? "Account created\nsuccessfully!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 26.sp,
                          // fontWeight: FontWeight.700,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),
                    ],
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
class ConfettiBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(42); // Stable seed for deterministic layout
    final List<Color> colors = [
      const Color(0xFFFF6B6B), // Red/Coral
      const Color(0xFF4D96FF), // Blue
      const Color(0xFF6BCB77), // Green
      const Color(0xFFFFD93D), // Yellow
      const Color(0xFF9B5DE5), // Purple
      const Color(0xFFFF9F1C), // Orange
    ];

    for (int i = 0; i < 45; i++) {
      final paint = Paint()
        ..color = colors[random.nextInt(colors.length)].withOpacity(0.65)
        ..style = PaintingStyle.fill
        ..strokeWidth = 3;

      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double scale = random.nextDouble() * 8 + 6;

      // Keep center somewhat clean
      
      if ((x - size.width / 2).abs() < 90 && (y - size.height / 2).abs() < 120) {
        continue;
      }

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble() * pi);

      int type = random.nextInt(4);
      if (type == 0) {
        // Rectangle / Square
        canvas.drawRect(Rect.fromLTWH(0, 0, scale, scale * 0.6), paint);
      } else if (type == 1) {
        // Dot / Circle
        canvas.drawCircle(Offset.zero, scale * 0.4, paint);
      } else if (type == 2) {
        // Triangle
        final path = Path()
          ..moveTo(0, -scale * 0.5)
          ..lineTo(scale * 0.5, scale * 0.5)
          ..lineTo(-scale * 0.5, scale * 0.5)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        // Squiggle / Line
        paint.style = PaintingStyle.stroke;
        final path = Path()..moveTo(-scale * 0.5, 0);
        path.quadraticBezierTo(0, -scale * 0.4, scale * 0.5, 0);
        canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}