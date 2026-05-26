import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/app_network_image.dart';
import '../../Profile/viewmodel/profile_viewmodel.dart';
import '../../Home/viewmodel/home_viewmodel.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required String imageUrl});
  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileViewModel, HomeViewModel>(builder: (context, profileProvider, homeVM, _) {
      final String avatarKey = profileProvider.selectedImage?.path
          ?? (homeVM.profileImage.isNotEmpty ? homeVM.profileImage : profileProvider.profileImageUrl);

      final imageWidget = profileProvider.selectedImage != null
          ? Image.file(profileProvider.selectedImage!, fit: BoxFit.cover)
          : (homeVM.profileImage.isNotEmpty)
              ? AppNetworkImage(
                  imageUrl: homeVM.profileImage,
                  fit: BoxFit.cover,
                  errorWidget: Image.network(AppImages.defaultProfile, fit: BoxFit.cover),
                )
              : (profileProvider.profileImageUrl.isNotEmpty)
                  ? AppNetworkImage(
                      imageUrl: profileProvider.profileImageUrl,
                      fit: BoxFit.cover,
                      errorWidget: Image.network(AppImages.defaultProfile, fit: BoxFit.cover),
                    )
                  : Image.network(AppImages.defaultProfile, fit: BoxFit.cover);

      return Container(
        height: 50.w,
        width: 50.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.grey, width: 1.w),
        ),
        child: ClipOval(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey(avatarKey),
              child: imageWidget,
            ),
          ),
        ),
      );
    });
  }
}
