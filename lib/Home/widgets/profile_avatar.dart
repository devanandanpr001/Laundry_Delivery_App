import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import '../../Profile/viewmodel/profile_viewmodel.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(builder: (context, provider, _) {
      final imageWidget = provider.selectedImage != null
          ? Image.file(provider.selectedImage!, fit: BoxFit.cover)
          : (provider.userProfile?.profileImageUrl != null && provider.userProfile!.profileImageUrl!.isNotEmpty)
              ? Image.network(provider.userProfile!.profileImageUrl!, fit: BoxFit.cover)
              : Image.network(AppImages.defaultProfile, fit: BoxFit.cover);

      return Container(
        height: 50.w,
        width: 50.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.grey, width: 1.w),
        ),
        child: ClipOval(child: imageWidget),
      );
    });
  }
  }