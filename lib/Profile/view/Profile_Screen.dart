import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/AuthSection/View/LogIn_screen.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/Notification/view/notification_screen.dart';
import 'package:ziya_laundry_deliveryapp/Profile/view/ChangePassword_Screen.dart';
import 'package:ziya_laundry_deliveryapp/Profile/view/ChangeProfileImage.dart';
import 'package:ziya_laundry_deliveryapp/Profile/view/Help&Support_Screen.dart';
import 'package:ziya_laundry_deliveryapp/Profile/view/MyOrders.dart';
import 'package:ziya_laundry_deliveryapp/Profile/view/PrivacyPolicy.dart';
import 'package:ziya_laundry_deliveryapp/Profile/viewmodel/profile_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/core/connectivity_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/BottomNavigation/CustomSmartRefresher.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/premium_dialog.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/advanced_image.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onBackToHome;
  const ProfileScreen({super.key, required this.onBackToHome});

  Future<void> showLogoutDialog(BuildContext context) async {
    final confirmed = await showPremiumLogoutDialog(context);
    if (confirmed) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: CustomSmartRefresher(
            onRefresh: () async {
              final connectivity = context.read<ConnectivityViewModel>();
              if (!await connectivity.refreshConnection()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppText.UrOffline)),
                );
                return;
              }
              await context.read<ProfileViewModel>().fetchProfileData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: onBackToHome,
                      icon: Icon(Icons.arrow_back_ios, size: 20.sp),
                    ),
                    Text(
                      AppText.TitleP,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Consumer<ProfileViewModel>(
                  builder: (context, provider, child) {
                    // final user = provider.userProfile; // kept via provider where needed

                    return Row(
                      children: [
                        Container(
                          height: 60.r,
                          width: 60.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 1.w),
                          ),
                          ////profile dp
                          child: ClipOval(
                            child: provider.selectedImage != null
                                ? Image.file(
                                    provider.selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : (provider.profileImageUrl.isNotEmpty == true)
                                    ? AdvancedCachedImage(
                                        imageUrl: provider.profileImageUrl,
                                        fit: BoxFit.cover,
                                        width: 60.r,
                                        height: 60.r,
                                        borderRadius: BorderRadius.circular(60.r),
                                      )
                                    : AdvancedCachedImage(
                                        imageUrl: AppImages.defaultProfile,
                                        fit: BoxFit.cover,
                                        width: 60.r,
                                        height: 60.r,
                                        borderRadius: BorderRadius.circular(60.r),
                                      ),
                          ),
                        ),
                        SizedBox(width: 13.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///name
                            Text(
                              provider
                                  .userName, // Use getter from ProfileViewModel
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ////number
                            Text(
                              '+91 ${provider.userPhone}', // Use getter from ProfileViewModel
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20.h),
                Text(
                  AppText.Orders,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                  ),
                ),
                SizedBox(height: 20.h),
                ContainerBox(
                  image: 'assets/icons/orders.png',
                  text: AppText.MyOdrBtn,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyOrdersScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                Text(
                  AppText.MyAcnt,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                  ),
                ),
                SizedBox(height: 20.h),
                ContainerBox(
                  image: 'assets/icons/edit.png',
                  text: AppText.ChangePfleBtn,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Changeprofileimage(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                ContainerBox(
                  image: 'assets/icons/lock.png',
                  text: AppText.ChangePswd,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangepasswordScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                ContainerBox(
                  image: 'assets/icons/notification.png',
                  text: AppText.Notfcn,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                Text(
                  AppText.Support,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                  ),
                ),
                SizedBox(height: 20.h),
                ContainerBox(
                  image: 'assets/icons/help.png',
                  text: AppText.SupportBtn,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpsupportScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                ContainerBox(
                  image: 'assets/icons/privacypolicy.png',
                  text: AppText.Privacy,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Privacypolicy()),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () {
                    showLogoutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softPink,
                    minimumSize: Size(double.infinity, 48.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red, size: 20.sp),
                      SizedBox(width: 5.w),
                      Text(
                        AppText.LogOut,
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      )
    );
  }

  Widget ContainerBox({
    required String image,
    required String text,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey, width: 1.w),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 12.w, right: 8.w),
          child: Row(
            children: [
              Image.asset(
                image,
                height: 20.w,
                width: 20.w,
                color: AppColors.primaryBlue,
              ),
              SizedBox(width: 10.w),
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkGrey,
                ),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios_outlined, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }
}
