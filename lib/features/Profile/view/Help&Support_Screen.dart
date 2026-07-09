import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/CustomSmartRefresher.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppLoader.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/data/models/help_support_model.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/viewmodel/help_support_controller.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';

class HelpsupportScreen extends StatefulWidget {
  const HelpsupportScreen({super.key});
  @override
  State<HelpsupportScreen> createState() => _HelpsupportScreenState();
}

class _HelpsupportScreenState extends State<HelpsupportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLoader.show();
      context.read<HelpSupportController>().fetchSupportData().then((_) {
        if (mounted) AppLoader.hide();
      }).catchError((_) {
        if (mounted) AppLoader.hide();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HelpSupportController>();
    final supportItems = controller.items;
    final isLoading = controller.isLoading;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(onPressed: () {
                    Navigator.pop(context);
                  }, icon: Icon(Icons.arrow_back_ios, size: 20.sp)),
                  Text(AppText.HelpAndSupportTitle,
                      style: GoogleFonts.poppins(
                          fontSize: 18.sp, fontWeight: FontWeight.w500)),
                ],
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: CustomSmartRefresher(
                  onRefresh: () async {
                    AppLoader.show();
                    try {
                      await controller.fetchSupportData();
                    } finally {
                      AppLoader.hide();
                    }
                  },
                  child: isLoading
                      ? const SizedBox.shrink()
                      : supportItems.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: 180.h),
                                Center(
                                  child: Text(
                                    "No support information available.",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14.sp, color: AppColors.grey),
                                  ),
                                ),
                              ],
                            )
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  EdgeInsets.symmetric(vertical: 12.h, horizontal: 0),
                              children: [
                                Text(
                                  AppText.HelpAndSupportSubtitle,
                                  style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryBlue),
                                ),
                                SizedBox(height: 20.h),
                                ...supportItems.map((item) => _buildFaqItem(item)),
                                SizedBox(height: 20.h),
                              ],
                            ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(HelpSupportItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black26,
            blurRadius: 6.r,
            offset: Offset(0, 3.h),
          )
        ],
      ),
      child: ExpansionTile(
        title: Text(
          item.question,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        childrenPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        children: [
          Text(
            item.answer,
            style: GoogleFonts.poppins(
                color: AppColors.black54, fontSize: 12.sp, height: 1.5),
          ),
        ],
      ),
    );
  }
}