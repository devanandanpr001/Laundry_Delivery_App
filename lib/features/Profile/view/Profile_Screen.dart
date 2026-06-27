import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/View/LogIn_screen.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ziya_laundry_deliveryapp/features/Notification/view/notification_screen.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/view/ChangePassword_Screen.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/view/ChangeProfileImage.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/view/Help&Support_Screen.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/view/MyOrders.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/view/PrivacyPolicy.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/viewmodel/profile_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/core/connectivity_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/CustomSmartRefresher.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/premium_dialog.dart';
import 'package:ziya_laundry_deliveryapp/core/widgets/no_internet_widget.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/widgets/advanced_image.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppLoader.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/viewmodel/login_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onBackToHome;
  const ProfileScreen({super.key, required this.onBackToHome});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Future<void> showLogoutDialog(BuildContext context) async {
    final confirmed = await showPremiumLogoutDialog(context);
    if (confirmed) {
      final loginVM = context.read<LoginViewModel>();
      AppLoader.navigateAndRemoveUntilWithTask(
        context,
        task: () async {
          context.read<ProfileViewModel>().clearAllCachedData();
          // Performs API call, socket disconnect, token delete, and remember me logic
          await loginVM.clearAllSavedData(); 
        },
        page: const LoginScreen(),
      );
    }
  }

  String? _fetchError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialLoad();
    });
  }

  Future<void> _initialLoad() async {
    if (mounted) setState(() => _fetchError = null);
    final profileVM = context.read<ProfileViewModel>();
    try {
      await profileVM.fetchProfileData();
    } catch (e) {
      if (mounted) setState(() => _fetchError = _parseError(e));
      debugPrint("ProfileScreen: Error during _initialLoad: $e");
    }
  }

  Future<void> _onRefresh() async {
    final connectivity = context.read<ConnectivityViewModel>();
    if (!await connectivity.refreshConnection()) {
      if (mounted) setState(() => _fetchError = "No internet connection");
      return;
    }
    final profileVM = context.read<ProfileViewModel>();
    try {
      if (mounted) setState(() => _fetchError = null);
      await profileVM.fetchProfileData();
    } catch (e) {
      if (mounted) setState(() => _fetchError = _parseError(e));
      debugPrint("ProfileScreen: Error during _onRefresh: $e");
    }
  }

  String _parseError(dynamic e) {
    String msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    final lower = msg.toLowerCase();
    if (lower.contains("socket") || lower.contains("network") || lower.contains("connection")) {
      return "No internet connection";
    }
    return msg.isEmpty ? "An unexpected error occurred" : msg;
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();
    final connectivityVM = context.watch<ConnectivityViewModel>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _fetchError != null && !profileVM.isLoading
          ? NoInternetWidget(
              message: _fetchError!,
              onRetry: () async {
                final connected = await connectivityVM.refreshConnection();
                if (connected) {
                  await _onRefresh();
                }
              },
            )
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: CustomSmartRefresher(
                  onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton( // Use widget.onBackToHome for StatelessWidget properties
                      onPressed: widget.onBackToHome,
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
                if (profileVM.isLoading)
                  _buildProfileHeaderShimmer()
                else
                  _buildProfileHeader(profileVM),
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
                if (profileVM.isLoading)
                  _buildBoxShimmer()
                else
                  ContainerBox(
                    image: 'assets/icons/orders.png',
                    text: AppText.MyOdrBtn,
                    onPressed: () {
                      AppLoader.navigateWithLoader(
                        context,
                        const MyOrdersScreen(),
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
                if (profileVM.isLoading) ...[
                   _buildBoxShimmer(),
                   SizedBox(height: 20.h),
                   _buildBoxShimmer(),
                   SizedBox(height: 20.h),
                   _buildBoxShimmer(),
                ] else ...[
                  ContainerBox(
                    image: 'assets/icons/edit.png',
                    text: AppText.ChangePfleBtn,
                    onPressed: () {
                      AppLoader.navigateWithLoader(
                        context,
                        const Changeprofileimage(),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  ContainerBox(
                    image: 'assets/icons/lock.png',
                    text: AppText.ChangePswd,
                    onPressed: () {
                      AppLoader.navigateWithLoader(
                        context,
                        const ChangepasswordScreen(),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  ContainerBox(
                    image: 'assets/icons/notification.png',
                    text: AppText.Notfcn,
                    onPressed: () {
                      AppLoader.navigateWithLoader(
                        context,
                        const NotificationScreen(),
                      );
                    },
                  ),
                ],
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
                if (profileVM.isLoading) ...[
                  _buildBoxShimmer(),
                  SizedBox(height: 20.h),
                  _buildBoxShimmer(),
                ] else ...[
                  ContainerBox(
                    image: 'assets/icons/help.png',
                    text: AppText.SupportBtn,
                    onPressed: () {
                      AppLoader.navigateWithLoader(
                        context,
                        const HelpsupportScreen(),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  ContainerBox(
                    image: 'assets/icons/privacypolicy.png',
                    text: AppText.Privacy,
                    onPressed: () {
                      AppLoader.navigateWithLoader(
                        context,
                        const Privacypolicy(),
                      );
                    },
                  ),
                ],
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

  Widget _buildProfileHeader(ProfileViewModel provider) {
    return Row(
      children: [
        Container(
          height: 60.r,
          width: 60.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 1.w),
          ),
          child: ClipOval(
            child: provider.selectedImage != null
                ? Image.file(provider.selectedImage!, fit: BoxFit.cover)
                : (provider.profileImageUrl.isNotEmpty)
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
            Text(
              provider.userName,
              style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w600),
            ),
            Text(
              '+91 ${provider.userPhone}',
              style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.darkGrey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileHeaderShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        children: [
          Container(height: 60.r, width: 60.r, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          SizedBox(width: 13.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 20.h, width: 150.w, color: Colors.white),
              SizedBox(height: 8.h),
              Container(height: 18.h, width: 100.w, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoxShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
      ),
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
