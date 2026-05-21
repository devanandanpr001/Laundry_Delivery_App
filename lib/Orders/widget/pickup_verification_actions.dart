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
  State<PickupVerificationActions> createState() => _PickupVerificationActionsState();
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
    // Sync the report state with existing data from backend
    if (widget.order.mismatchReason != null && widget.order.mismatchReason!.isNotEmpty) {
      _mismatchController.text = widget.order.mismatchReason!;
      _lastSentReportText = widget.order.mismatchReason!;
      _reportSentSuccess = true;
    }
    _mismatchController.addListener(_onMismatchTextChanged);
  }

  void _onMismatchTextChanged() {
    if (!mounted) return;
    setState(() => _isUserEditing = _mismatchController.text.trim() != _lastSentReportText);
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

    final success = await orderVM.reportItemMismatch(widget.orderId, reportText);

    if (mounted) {
      setState(() {
        _isSendingReport = false;
        if (success) {
          _reportSentSuccess = true;
          _lastSentReportText = reportText;
          _isUserEditing = false;
          AppToast.showSuccess(
            title: "Success",
            message: "Report successfully sent",
          );
        } else {
          _reportSentFailed = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isVerified = widget.order.isVerified;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      side: BorderSide(color: AppColors.primaryBlue, width: 1.r),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.all(8.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 16.sp, color: AppColors.primaryBlue),
                        SizedBox(width: 8.w),
                        Text("Add", style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
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
                            } finally {
                              if (mounted) setState(() => _isVerifying = false);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isVerified ? AppColors.green : AppColors.primaryBlue,
                      disabledBackgroundColor: isVerified ? AppColors.green : null,
                      disabledForegroundColor: isVerified ? Colors.white : null,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.all(8.w),
                    ),
                    child: _isVerifying
                        ? LoadingAnimationWidget.waveDots(color: Colors.white, size: 18.sp)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 16.sp, color: Colors.white),
                              SizedBox(width: 8.w),
                              Text("Checked",
                                  style: GoogleFonts.poppins(
                                      fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isVerified && (widget.isModified || (widget.order.mismatchReason != null && widget.order.mismatchReason!.isNotEmpty)))
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Report Item Mismatch", style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.errorRed)),
                    const Spacer(),
                    if (_reportSentSuccess && _mismatchController.text.trim() == _lastSentReportText && _lastSentReportText.isNotEmpty)
                      Icon(Icons.check_circle, color: AppColors.green, size: 18.sp),
                    if (_reportSentFailed)
                      Icon(Icons.error, color: AppColors.errorRed, size: 18.sp),
                  ],
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: _mismatchController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Type mismatch details here...",
                    hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.5))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                    contentPadding: EdgeInsets.all(10.w),
                  ),
                  style: GoogleFonts.poppins(fontSize: 13.sp),
                ),
                if (_mismatchController.text.trim() != _lastSentReportText)
                // Show buttons if text has changed from what was sent, or if never sent successfully.
                if (_isUserEditing || !_reportSentSuccess)
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _reportSentFailed = false;
                                if (_lastSentReportText.isEmpty) _reportSentSuccess = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.grey),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                            child: Text("Clear", style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.grey, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (_isSendingReport || _mismatchController.text.trim().isEmpty)
                                ? null
                                : _handleMismatchReportSubmission,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              disabledBackgroundColor: AppColors.grey,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                            child: _isSendingReport
                                ? LoadingAnimationWidget.waveDots(color: Colors.white, size: 18.sp)
                                : Text(
                                    _lastSentReportText.isEmpty ? "Enter" : "Resend",
                                    style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        Divider(color: AppColors.grey.withValues(alpha: 0.5)),
      ],
    );
  }
}