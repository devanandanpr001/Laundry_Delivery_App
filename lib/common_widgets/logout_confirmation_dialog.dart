import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';

/// Premium logout confirmation dialog with smooth animations and modern design
class LogoutConfirmationDialog extends StatefulWidget {
  final VoidCallback onLogoutConfirmed;
  final VoidCallback? onCancel;
  final bool isLoading;

  const LogoutConfirmationDialog({
    super.key,
    required this.onLogoutConfirmed,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<LogoutConfirmationDialog> createState() => _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController; // Fixed: Added late keyword
  late Animation<double> _scaleAnimation; // Fixed: Added late keyword
  late Animation<double> _fadeAnimation; // Fixed: Added late keyword
  late Animation<Offset> _slideAnimation; // Fixed: Added late keyword

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// Dark blur overlay background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),

                /// Main white container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 32.h),

                      /// Logout icon container with gradient background
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFF6B6B).withOpacity(0.15),
                              const Color(0xFFEE5A52).withOpacity(0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B6B).withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
                          margin: EdgeInsets.all(16.w),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFF6B6B),
                                Color(0xFFEE5A52),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 40.sp,
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      /// Title
                      Text(
                        'Logout',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black87,
                          letterSpacing: -0.3,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      /// Subtitle
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          'Are you sure you want to logout from Laundry Delivery?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black87,
                            height: 1.4,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      /// Helper text
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          'You will need to login again to access your account.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black54,
                            height: 1.4,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),

                      SizedBox(height: 28.h),

                      /// Action buttons
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            /// Cancel button
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.isLoading
                                      ? null
                                      : () {
                                          Navigator.pop(context);
                                          widget.onCancel?.call();
                                        },
                                  borderRadius: BorderRadius.circular(14.r),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: AppColors.grey,
                                        width: 1.2,
                                      ),
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                      horizontal: 16.w,
                                    ),
                                    child: Text(
                                      'Cancel',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black87,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 12.w),

                            /// Logout button
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.isLoading
                                      ? null
                                      : () {
                                          widget.onLogoutConfirmed.call();
                                        },
                                  borderRadius: BorderRadius.circular(14.r),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFFF6B6B),
                                          Color(0xFFEE5A52),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF6B6B).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                      horizontal: 16.w,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (widget.isLoading) ...[
                                          SizedBox(
                                            width: 16.w,
                                            height: 16.w,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              valueColor: // Fixed: Removed const from AlwaysStoppedAnimation
                                                  const AlwaysStoppedAnimation<Color>( 
                                                      Colors.white),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                        ] else
                                          Icon(
                                            Icons.logout,
                                            color: Colors.white,
                                            size: 18.sp,
                                          ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          widget.isLoading ? 'Logging out...' : 'Logout',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: -0.2,
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
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to show logout confirmation dialog
Future<bool?> showLogoutConfirmationDialog(
  BuildContext context, {
  required VoidCallback onLogoutConfirmed,
  VoidCallback? onCancel,
  bool isLoading = false,
}) {
  return showDialog<bool?>( // Fixed: Removed const from showDialog
    context: context,
    barrierDismissible: !isLoading,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) => LogoutConfirmationDialog(
      onLogoutConfirmed: onLogoutConfirmed,
      onCancel: onCancel,
      isLoading: isLoading,
    ),
  );
}
