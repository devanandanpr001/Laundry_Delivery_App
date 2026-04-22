import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class TopRightCurveClipper extends CustomClipper<Path> {
  final double curveHeight;

  TopRightCurveClipper({this.curveHeight = 160});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width - curveHeight.w, 0);
    path.quadraticBezierTo(size.width, 0, size.width, curveHeight.h);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}