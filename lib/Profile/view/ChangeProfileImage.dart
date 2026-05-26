import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/AuthSection/widgets/custom_button.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Profile/viewmodel/profile_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';

class Changeprofileimage extends StatefulWidget {
  const Changeprofileimage({super.key});

  @override
  State<Changeprofileimage> createState() => _ChangeprofileimageState();
}

class _ChangeprofileimageState extends State<Changeprofileimage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      File imageFile = File(pickedFile.path);
      Provider.of<ProfileViewModel>(context, listen: false).setPickedImage(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios, size: 20.sp),
                  ),
                  Text(
                    AppText.TitleProfile,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25.h),

              /// PROFILE IMAGE
              Consumer<ProfileViewModel>(
                builder: (context, provider, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Container(
                      key: ValueKey(provider.selectedImage?.path ?? provider.profileImageUrl),
                      height: 120.h,
                      width: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.grey, width: 1.w),
                      ),
                      child: ClipOval(
                        child: provider.selectedImage != null
                            ? Image.file(
                                provider.selectedImage!,
                                fit: BoxFit.cover,
                              )
                            : provider.profileImageUrl.isNotEmpty
                                  ? Image.network(
                                      provider.profileImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.network(
                                                AppImages.defaultProfile,
                                                fit: BoxFit.cover,
                                              ),
                                    )
                                  : Image.network(
                                      AppImages.defaultProfile,
                                      fit: BoxFit.cover,
                                    ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 30.h), // Increased spacing for better UI
              /// CHANGE BUTTON
              CustomButton(
                text: AppText.BtnProfile,
                onPressed: _pickImage,
                backgroundColor: AppColors.grey.withOpacity(0.2),
                textColor: AppColors.black, // Now supported by CustomButton
                fontWeight: FontWeight.w500,
                height: 42.h,
                borderRadius: 8.r,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),

              // Spacing between buttons
              SizedBox(height: 15.h),

              /// SAVE BUTTON
              Consumer<ProfileViewModel>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: provider.isLoading ? "Uploading..." : "Save Changes",
                    onPressed:
                        (provider.selectedImage == null || provider.isLoading)
                        ? null // Button is disabled if no image selected or loading
                        : () async {
                            await provider.uploadProfileImage();
                            if (!context.mounted) return;
                            if (provider.errorMessage == null) {
                              AppToast.showSuccess(
                                title: "Success",
                                message: "Profile image updated successfully",
                              );
                            } else {
                              AppToast.showError(
                                title: "Upload Failed",
                                message: provider.errorMessage!,
                              );
                            }
                          },
                    backgroundColor: AppColors.primaryBlue,
                    height: 48.h,
                    borderRadius: 8.r,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
