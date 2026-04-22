import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/order_viewmodel.dart';

import '../../Orders/data/model/order_model.dart';

  class MyOrdersScreen extends StatelessWidget {
    const MyOrdersScreen({super.key});

    @override
    Widget build(BuildContext context) {
      final orderVM = context.watch<OrderViewModel>();
      final orders = orderVM.orders;
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  children: [
                     IconButton(onPressed: (){
                       Navigator.pop(context);
                     },
                         icon: Icon(Icons.arrow_back_ios, size: 20.sp)),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppText.TitleMy,
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${orders.length} ${AppText.OrderPlural}",
                          style: GoogleFonts.poppins(
                              fontSize: 14.sp,fontWeight: FontWeight.w400,color: AppColors.black87),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20.h),
                
                if (orderVM.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else

                Expanded(
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];

                      return MyOrderCard(
                        orderId: order.orderId,
                        status: order.status == OrderStatus.completed
                            ? "delivered"
                            : "out",
                        time: AppText.Today, // you can customize
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    Widget sectionTitle(String title) {
      return Padding(
        padding: EdgeInsets.only(left: 13.w),
        child: Row(
          children: [
            Text(
              title,
              style:  GoogleFonts.poppins(
                  color: AppColors.grey,fontSize: 14.sp,fontWeight: FontWeight.w400),
            ),
            const Expanded(
              child: Divider(thickness: 1), // Standard dividers usually don't need scaling, but 1.h can be used for precision
            )
          ],
        ),
      );
    }
  }


  class MyOrderCard extends StatelessWidget {
    final String status;
    final String time;
    final String orderId;

    const MyOrderCard({
      super.key,
      required this.status,
      required this.time,
      required this.orderId,
    });

    @override
    Widget build(BuildContext context) {
      bool isDelivered = status == "delivered";

      return Container(
        height: 110.w,
        margin: EdgeInsets.only(bottom: 15.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(offset: Offset(0, 4.h),
              blurRadius: 6.r,
              color: AppColors.black12,
            )
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.w, top: 4.h, bottom: 15.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ORDER ID
                  Row(
                    children: [
                      Text(
                        AppText.OrderId,
                        style:  GoogleFonts.poppins(
                          fontSize: 16.sp,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        orderId,
                        style:  GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  /// STATUS
                  Row(
                    children: [
                      Image.asset(
                        isDelivered
                            ? AppImages.iconCheck
                            : AppImages.iconNoCircle,
                        color: isDelivered ? AppColors.green : AppColors.red,height: 20.h,width: 20.w,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        isDelivered
                            ? AppText.OrderDeliveredTitle
                            : AppText.OutForDelivery,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color:
                          isDelivered ? AppColors.green : AppColors.red,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  /// LOCATION
                  Row(
                    children:  [
                      Image.asset(AppImages.iconLocation,height: 20.h,width: 20.w,color: AppColors.primaryBlue,),
                      SizedBox(width: 4.w),
                      Text(
                        AppText.Pathalam,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// TIME BADGE
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.timeBadgeBlue,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  time,
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }