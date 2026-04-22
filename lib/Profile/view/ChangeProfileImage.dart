import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/AuthSection/widgets/custom_button.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Profile/viewmodel/profile_viewmodel.dart';

  class Changeprofileimage extends StatefulWidget {
    const Changeprofileimage({super.key});

    @override
    State<Changeprofileimage> createState() => _ChangeprofileimageState();
  }

  class _ChangeprofileimageState extends State<Changeprofileimage> {

    final ImagePicker _picker = ImagePicker();

    Future<void> _pickImage() async {
      final pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        context.read<ProfileViewModel>().setPickedImage(imageFile);
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
                        icon: Icon(Icons.arrow_back_ios, size: 20.sp)),
                    Text(
                      AppText.TitleProfile,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 25.h),

                /// PROFILE IMAGE
                Consumer<ProfileViewModel>(builder: (context,provider,child){
                  return Container(
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
                          : Image.network(AppImages.defaultProfile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),

                SizedBox(height: 10.h),

                /// CHANGE BUTTON
                CustomButton(
                  text: AppText.BtnProfile,
                  onPressed: _pickImage,
                  backgroundColor: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                  height: 42.h,
                  borderRadius: 8.r,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }