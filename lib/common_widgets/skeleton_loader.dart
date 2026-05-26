import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
// No font usage required here

class PremiumSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Widget? child;

  const PremiumSkeleton({super.key, this.width = double.infinity, this.height = 12, this.borderRadius, this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 900),
      child: Container(
        width: width,
        height: height.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        ),
        child: child,
      ),
    );
  }
}

class PremiumSkeletonList extends StatelessWidget {
  final int count;
  final IndexedWidgetBuilder itemBuilder;
  const PremiumSkeletonList({super.key, required this.count, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (index) => itemBuilder(context, index)),
    );
  }
}
