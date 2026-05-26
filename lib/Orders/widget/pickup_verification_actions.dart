import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/order_viewmodel.dart';

class PickupVerificationActions extends StatefulWidget {
  final OrderModel order;
  final String orderId;
  final String by;
  final bool isModified;
  final VoidCallback onShowAddItemDialog;

  const PickupVerificationActions({
    super.key,
    required this.order,
    required this.orderId,
    required this.by,
    required this.isModified,
    required this.onShowAddItemDialog,
  });

  @override
  State<PickupVerificationActions> createState() =>
      _PickupVerificationActionsState();
}

class _PickupVerificationActionsState extends State<PickupVerificationActions> {
  bool _isVerifying = false;
  final TextEditingController _mismatchController = TextEditingController();
  bool _isSendingReport = false;
  bool _reportSentSuccess = false;
  bool _reportSentFailed = false;
  String _lastSentReportText = "";
  bool _isUserEditing = false;

  @override
  void initState() {
    super.initState();
    _syncControllerWithBackend();
    _mismatchController.addListener(_onMismatchTextChanged);
  }

  @override
  void didUpdateWidget(covariant PickupVerificationActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync internal state if the order data from parent/backend changes
    if (widget.order.mismatchReason != oldWidget.order.mismatchReason) {
      _syncControllerWithBackend();
    }
  }

  void _syncControllerWithBackend() {
    if (widget.order.mismatchReason != null &&
        widget.order.mismatchReason!.isNotEmpty) {
      _mismatchController.text = widget.order.mismatchReason!;
      _lastSentReportText = widget.order.mismatchReason!;
      _reportSentSuccess = true;
    } else if (!_isUserEditing) {
      _reportSentSuccess = false;
      _lastSentReportText = "";
    }
  }

  void _onMismatchTextChanged() {
    if (!mounted) return;
    setState(
      () => _isUserEditing =
          _mismatchController.text.trim() != _lastSentReportText,
    );
  }

  @override
  void dispose() {
    _mismatchController.dispose();
    super.dispose();
  }

  Future<void> _handleMismatchReportSubmission() async {
    final orderVM = context.read<OrderViewModel>();
    final reportText = _mismatchController.text.trim();
    setState(() {
      _isSendingReport = true;
      _reportSentFailed = false;
    });

    final success = await orderVM.reportItemMismatch(
      widget.orderId,
      reportText,
    );

    if (mounted) {
      setState(() {
        _isSendingReport = false;
        if (success) {
          _reportSentSuccess = true;
          _lastSentReportText = reportText;
          _isUserEditing = false;
          AppToast.showSuccess(
            title: "Success",
            message: "Mismatch report submitted successfully",
          );
        } else {
          _reportSentFailed = true;
          AppToast.showError(
            title: "Failed",
            message: "Unable to submit mismatch report. Please try again.",
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isVerified = widget.order.isVerified;
    // Show mismatch section ONLY if items were modified (locally or on backend)
    final bool shouldShowMismatchSection =
        isVerified && (widget.isModified || widget.order.isMismatch);

    // REQUIRED: items were modified and nothing is submitted yet
    final bool isRequiredWarning =
        (widget.isModified || widget.order.isMismatch) && !_reportSentSuccess;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verification Section
        Padding(
          padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
          child: Row(
            children: [
              if (widget.by == "Per Piece" && !isVerified) ...[
                SizedBox(
                  width: 136.w,
                  height: 32.h,
                  child: OutlinedButton(
                    onPressed: widget.onShowAddItemDialog,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.primaryBlue,
                        width: 1.r,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.all(8.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 16.sp,
                          color: AppColors.primaryBlue,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Add",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: SizedBox(
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: (!isVerified && !_isVerifying)
                        ? () async {
                            final orderVM = context.read<OrderViewModel>();
                            setState(() => _isVerifying = true);
                            try {
                              await orderVM.verifyOrder(widget.orderId);
                              if (mounted) setState(() {});
                            } finally {
                              if (mounted) setState(() => _isVerifying = false);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isVerified
                          ? AppColors.green
                          : AppColors.primaryBlue,
                      disabledBackgroundColor: isVerified
                          ? AppColors.green
                          : null,
                      disabledForegroundColor: isVerified ? Colors.white : null,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.all(8.w),
                    ),
                    child: _isVerifying
                        ? LoadingAnimationWidget.waveDots(
                            color: Colors.white,
                            size: 18.sp,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isVerified
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                size: 16.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                isVerified ? "Verified" : "Check Items",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Report Item Mismatch Section - REQUIRED if items modified
        if (shouldShowMismatchSection)
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isRequiredWarning
                  ? AppColors.errorRed.withValues(alpha: 0.06)
                  : AppColors.green.withValues(alpha: 0.05),
              border: Border.all(
                color: isRequiredWarning
                    ? AppColors.errorRed.withValues(alpha: 0.45)
                    : AppColors.green.withValues(alpha: 0.4),
                width: 1.3.r,
              ),
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: isRequiredWarning
                      ? AppColors.errorRed.withValues(alpha: 0.1)
                      : AppColors.green.withValues(alpha: 0.06),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Container(
                  padding: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.grey.withValues(alpha: 0.2),
                        width: 0.8.r,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: isRequiredWarning
                              ? AppColors.errorRed.withValues(alpha: 0.15)
                              : AppColors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          isRequiredWarning
                              ? Icons.warning_amber_rounded
                              : Icons.verified_rounded,
                          color: isRequiredWarning
                              ? AppColors.errorRed
                              : AppColors.green,
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRequiredWarning
                                  ? "Report Discrepancies"
                                  : "Verification Complete",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              isRequiredWarning
                                  ? "Required - Please report any discrepancies"
                                  : "All items verified successfully",
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      if (_reportSentSuccess && _lastSentReportText.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.green,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "Submitted",
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_reportSentFailed)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error,
                                color: AppColors.errorRed,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "Failed",
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  color: AppColors.errorRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Always allow reporting if verified
                SizedBox(height: 12.h),
                Text(
                  "Describe the discrepancy (Required):",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _mismatchController,
                  maxLines: 3,
                  minLines: 2,
                  decoration: InputDecoration(
                    hintText:
                        "e.g., Missing items, damaged items, quantity mismatch...",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: AppColors.hintGrey,
                      fontStyle: FontStyle.italic,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: AppColors.grey.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue,
                        width: 1.5.r,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: AppColors.grey.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    contentPadding: EdgeInsets.all(10.w),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.textDark,
                  ),
                ),
                if (_isUserEditing ||
                    (!_reportSentSuccess && widget.isModified))
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: _mismatchController.text.trim().isEmpty
                                ? null
                                : () {
                                    setState(() {
                                      _mismatchController.clear();
                                      _reportSentFailed = false;
                                      _isUserEditing = false;
                                    });
                                  },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _mismatchController.text.trim().isEmpty
                                    ? AppColors.grey.withValues(alpha: 0.4)
                                    : AppColors.errorRed.withValues(alpha: 0.6),
                                width: 1.r,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                            ),
                            child: Text(
                              "Clear",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: _mismatchController.text.trim().isEmpty
                                    ? AppColors.grey
                                    : AppColors.errorRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed:
                                (_isSendingReport ||
                                    _mismatchController.text.trim().isEmpty)
                                ? null
                                : _handleMismatchReportSubmission,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              disabledBackgroundColor: AppColors.grey
                                  .withValues(alpha: 0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                            ),
                            child: _isSendingReport
                                ? SizedBox(
                                    height: 16.sp,
                                    width: 16.sp,
                                    child: LoadingAnimationWidget.waveDots(
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                  )
                                : Text(
                                    _lastSentReportText.isEmpty
                                        ? "Submit Report"
                                        : "Update Report",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (shouldShowMismatchSection)
          Divider(color: AppColors.grey.withValues(alpha: 0.5), thickness: 0.8),
      ],
    );
  }
}
