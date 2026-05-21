import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';

class AddImageButton extends StatefulWidget {
  final Future<void> Function() onAddImage;

  const AddImageButton({
    super.key,
    required this.onAddImage,
  });

  @override
  State<AddImageButton> createState() => _AddImageButtonState();
}

class _AddImageButtonState extends State<AddImageButton> {
  bool _isAddingImage = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: SizedBox(
        width: double.infinity,
        height: 40.h,
        child: OutlinedButton.icon(
          onPressed: _isAddingImage ? null : () async {
            setState(() => _isAddingImage = true);
            try {
              await widget.onAddImage();
            } finally {
              if (mounted) setState(() => _isAddingImage = false);
            }
          },
          icon: _isAddingImage
              ? const SizedBox.shrink()
              : Icon(Icons.add_a_photo, size: 20.sp, color: AppColors.primaryBlue),
          label: _isAddingImage
              ? LoadingAnimationWidget.waveDots(color: AppColors.primaryBlue, size: 20.sp)
              : Text(
                  "Add Image",
                  style: GoogleFonts.poppins(
                      fontSize: 14.sp, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primaryBlue, width: 1.r),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        ),
      ),
    );
  }
}