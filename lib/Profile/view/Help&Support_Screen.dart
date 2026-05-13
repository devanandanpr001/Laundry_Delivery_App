import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Profile/data/repository/help_support_repository.dart';
import 'package:ziya_laundry_deliveryapp/Profile/data/service/help_support_service.dart';
import 'package:ziya_laundry_deliveryapp/Profile/data/models/help_support_model.dart';
import 'package:ziya_laundry_deliveryapp/Profile/viewmodel/help_support_controller.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/core/dio_client.dart';

class HelpsupportScreen extends StatefulWidget {
  const HelpsupportScreen({super.key});
  @override
  State<HelpsupportScreen> createState() => _HelpsupportScreenState();
}

class _HelpsupportScreenState extends State<HelpsupportScreen> {
  late HelpSupportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HelpSupportController(
      HelpSupportRepository(
        HelpSupportService(DioClient()),
      ),
    );
    _controller.fetchSupportData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
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
                IconButton(onPressed: (){
                  Navigator.pop(context);
                },
                  icon: Icon(Icons.arrow_back_ios, size: 20.sp),),
                Text(AppText.HelpAndSupportTitle,style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500
                ),)
              ],
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  if (_controller.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      ),
                    );
                  }

                  if (_controller.supportItems.isEmpty) {
                    return Center(
                      child: Text(
                        "No support information available.",
                        style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.grey),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          AppText.HelpAndSupportSubtitle,
                          style: GoogleFonts.poppins(
                              fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.primaryBlue),
                        ),
                        SizedBox(height: 20.h),
                        ..._controller.supportItems.map((item) => _buildFaqItem(item)).toList(),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  );
                },
              ),
            )
                    ],
                  ),
          )),
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
            style: GoogleFonts.poppins(color: AppColors.black54, fontSize: 12.sp, height: 1.5),
          ),
        ],
      ),
    );
  }
}
