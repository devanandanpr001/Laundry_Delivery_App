import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';

class HelpsupportScreen extends StatelessWidget {
  const HelpsupportScreen({super.key});

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
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(AppText.HelpAndSupportSubtitle,style: GoogleFonts.poppins(
                                  fontSize: 14.sp,fontWeight: FontWeight.w500,color: AppColors.primaryBlue
                              ),),
                              SizedBox(height: 20.h,),

                              /// Delivery Issues
                              Container(
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
                                  leading: Text(AppText.DeliveryIssuesTitle,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600, fontSize: 14.sp
                                    ),),
                                  title: const Text(''),
                                  childrenPadding:
                                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                  children: [
                                    Text(
                                      AppText.DeliveryIssuesDescription,
                                      style: GoogleFonts.poppins(color: AppColors.black54,fontSize: 12.sp),
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        Icon(Icons.phone, size: 20.sp),
                                        SizedBox(width: 8.w),
                                        Text(AppText.DeliveryIssuesContact),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 5.h,),

                              /// Salary
                              Container(
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
                                  leading: Text(AppText.SalaryIncentivesTitle,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600, fontSize: 14.sp
                                    ),),
                                  title: const Text(''),
                                  childrenPadding:
                                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                  children: [
                                    Text(
                                      AppText.DeliveryIssuesDescription,
                                      style: GoogleFonts.poppins(color: AppColors.black54,fontSize: 12.sp),
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        Icon(Icons.phone, size: 20.sp),
                                        SizedBox(width: 8.w),
                                        Text(AppText.DeliveryIssuesContact),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 5.h,),

                              /// App Technical issues
                              Container(
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
                                  leading: Text(AppText.AppTechnicalIssuesTitle,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600, fontSize: 14.sp
                                    ),),
                                  title: const Text(''),
                                  childrenPadding:
                                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                  children: [
                                    Text(
                                      AppText.DeliveryIssuesDescription,
                                      style: GoogleFonts.poppins(color: AppColors.black54,fontSize: 12.sp),
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        Icon(Icons.phone, size: 20.sp),
                                        SizedBox(width: 8.w),
                                        Text(AppText.DeliveryIssuesContact),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h,),

                              Container(
                                height: 123.h,
                                width: 1.sw,
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
                                child: Padding(
                                  padding: EdgeInsets.only(left: 17.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(AppText.EmergencyTitle,style: GoogleFonts.poppins(
                                        fontSize: 14.sp,fontWeight: FontWeight.w600
                                      ),),
                                      const Text(AppText.EmergencyDescription),
                                      Text(AppText.EmergencyContact,style: GoogleFonts.poppins(
                                          fontSize: 14.sp,fontWeight: FontWeight.w400
                                      ),)
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h,),

                              Container(
                                height: 230.h,
                                width: 1.sw,
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
                                child: Padding(
                                  padding: EdgeInsets.only(left: 17.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(AppText.ReportIssuesTitle,style: GoogleFonts.poppins(
                                          fontSize: 14.sp,fontWeight: FontWeight.w600
                                      ),),
                                      const Text(AppText.ReportIssuesInstruction1),
                                      const Text(AppText.ReportIssuesBullet1),
                                      const Text(AppText.ReportIssuesBullet2),
                                      const Text(AppText.ReportIssuesBullet3),
                                      const Text(AppText.ReportIssuesInstruction2),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 200.h,),
                              Text(AppText.ManagementCommitment,style: GoogleFonts.poppins(
                                fontSize: 14.sp,fontWeight: FontWeight.w400
                              ),)
                            ],
                          ),
                        ),
                      )

                      
                    ],
                  ),
          )),
    );
  }
}
