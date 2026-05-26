import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
// app_shimmer uses neutral colors and doesn't require AppColors

/// Centralized shimmer loading effects for the entire app
class AppShimmer {
  static const Color _baseColor = Color(0xFFEFF6FF);
  static const Color _highlightColor = Color(0xFFDCEEFF);

  /// Base shimmer wrapper
  static Widget _buildShimmer({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      period: duration,
      direction: ShimmerDirection.ltr,
      child: child,
    );
  }

  /// Order Card Shimmer
  static Widget orderCard() {
    return _buildShimmer(
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 100.w,
                  height: 16.h,
                  color: Colors.white,
                ),
                const Spacer(),
                Container(
                  width: 60.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Name and address
            Container(
              width: 200.w,
              height: 14.h,
              color: Colors.white,
            ),
            SizedBox(height: 6.h),
            Container(
              width: 250.w,
              height: 12.h,
              color: Colors.white,
            ),
            SizedBox(height: 16.h),
            // Items section
            Container(
              width: 150.w,
              height: 14.h,
              color: Colors.white,
            ),
            SizedBox(height: 8.h),
            Row(
              children: List.generate(
                3,
                (index) => Container(
                  margin: EdgeInsets.only(right: 8.w),
                  width: 60.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Action buttons
            Row(
              children: [
                Container(
                  width: 80.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 80.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Status Count Card Shimmer
  static Widget statusCard() {
    return _buildShimmer(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: 60.w,
              height: 14.h,
              color: Colors.white,
            ),
            SizedBox(height: 8.h),
            Container(
              width: 30.w,
              height: 20.h,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  /// Notification Item Shimmer
  static Widget notificationItem() {
    return _buildShimmer(
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200.w,
                    height: 14.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    width: 150.w,
                    height: 12.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    width: 80.w,
                    height: 10.h,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Profile/Order List Item Shimmer
  static Widget listItem() {
    return _buildShimmer(
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 180.w,
                    height: 16.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    width: 120.w,
                    height: 12.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 40.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 80.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CMS Content Shimmer
  static Widget cmsContent() {
    return _buildShimmer(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Container(
              width: 200.w,
              height: 24.h,
              color: Colors.white,
            ),
            SizedBox(height: 16.h),
            // Content lines
            Container(
              width: double.infinity,
              height: 14.h,
              color: Colors.white,
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              height: 14.h,
              color: Colors.white,
            ),
            SizedBox(height: 8.h),
            Container(
              width: 300.w,
              height: 14.h,
              color: Colors.white,
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              height: 14.h,
              color: Colors.white,
            ),
            SizedBox(height: 8.h),
            Container(
              width: 250.w,
              height: 14.h,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  /// Service Item Shimmer
  static Widget serviceItem() {
    return _buildShimmer(
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              color: Colors.white,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Container(
                width: double.infinity,
                height: 16.h,
                color: Colors.white,
              ),
            ),
            Container(
              width: 60.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generic Rectangle Shimmer
  static Widget rectangle({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return _buildShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(4.r),
        ),
      ),
    );
  }

  /// Generic Circle Shimmer
  static Widget circle({required double size}) {
    return _buildShimmer(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// List of shimmer items
  static Widget list({
    required Widget Function() itemBuilder,
    int itemCount = 5,
  }) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(),
    );
  }

  /// Grid of shimmer items
  static Widget grid({
    required Widget Function() itemBuilder,
    int itemCount = 6,
    int crossAxisCount = 2,
  }) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(),
    );
  }
}
