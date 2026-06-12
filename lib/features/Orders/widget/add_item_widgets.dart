import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';

/// A consistent label widget for form fields in the Add Item dialog.
class AddItemLabel extends StatelessWidget {
  final String text;
  const AddItemLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(text,
          style: GoogleFonts.poppins(
              fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black)),
    );
  }
}

/// A reusable dropdown trigger button for selection fields.
class AddItemDropdownTrigger extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isOpen;
  final double? width;

  const AddItemDropdownTrigger({
    super.key,
    required this.text,
    required this.onTap,
    required this.isOpen,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 134.w,
        height: 32.h,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1.w),
            borderRadius: BorderRadius.circular(8.r)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: Text(text,
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black54),
                    overflow: TextOverflow.ellipsis)),
            Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.black, size: 16.sp),
          ],
        ),
      ),
    );
  }
}

/// Container for dropdown list content.
class AddItemDropdownContent extends StatelessWidget {
  final Widget child;
  const AddItemDropdownContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4.h),
      constraints: BoxConstraints(maxHeight: 200.h),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8.r)),
      child: child,
    );
  }
}

/// Reusable action button for incrementing/decrementing quantities.
class AddItemQuantityAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AddItemQuantityAction({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      child: Container(
        width: 50.w,
        height: 25.h,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(5.r)),
        child: Center(
            child: Text(label,
                style: GoogleFonts.poppins(fontSize: 18.sp, color: Colors.black))),
      ));
}

/// Displays a bulleted list of selected service names.
class SelectedServicesDisplay extends StatelessWidget {
  final Set<String> selectedServiceIds;
  final List<Map<String, dynamic>> availableServices;

  const SelectedServicesDisplay({
    super.key,
    required this.selectedServiceIds,
    required this.availableServices,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedServiceIds.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: selectedServiceIds.map((id) {
          final service = availableServices.firstWhere(
            (s) => s['id']?.toString() == id,
            orElse: () => {},
          );
          return Text(
            "• ${service['name'] ?? ''}",
            style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.linkBlue),
          );
        }).toList(),
      ),
    );
  }
}

/// The central quantity counter display.
class QuantityCounter extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantityCounter({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AddItemQuantityAction(label: "-", onTap: onDecrement),
        SizedBox(width: 12.w),
        Container(
          width: 48.w,
          height: 36.w,
          decoration: BoxDecoration(
              color: const Color(0xFF0064D7), borderRadius: BorderRadius.circular(4.r)),
          child: Center(
              child: Text(quantity.toString(),
                  style: GoogleFonts.poppins(
                      fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white))),
        ),
        SizedBox(width: 12.w),
        AddItemQuantityAction(label: "+", onTap: onIncrement),
      ],
    );
  }
}

/// The primary action button for the Add Item dialog.
class AddItemSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const AddItemSubmitButton({super.key, required this.isLoading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 32.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          elevation: 0,
          disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.6),
        ),
        child: isLoading
            ? LoadingAnimationWidget.waveDots(color: Colors.white, size: 20.sp)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text("Add Items",
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}