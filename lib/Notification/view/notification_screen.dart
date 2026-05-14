import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/BottomNavigation/CustomSmartRefresher.dart';
import '../viewmodel/notification_viewmodel.dart';
import '../widgets/notification_item_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isDeleteMode = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  /// Handles the deletion with slide animation
  void _handleAnimatedDelete(NotificationViewModel vm) {
    final list = vm.notificationList;
    // Iterate backwards to maintain correct indices during removal
    for (int i = list.length - 1; i >= 0; i--) {
      if (list[i].isSelected) {
        final removedItem = list[i];
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => SlideTransition(
            position: animation.drive(Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOut))),
            child: NotificationItemWidget(
              title: removedItem.title,
              time: removedItem.time,
              orderId: removedItem.orderId,
              isSelected: true,
              isSelectionMode: true,
            ),
          ),
          duration: const Duration(milliseconds: 400),
        );
        vm.removeAt(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationVM = context.watch<NotificationViewModel>();
    final notifications = notificationVM.notificationList;
    bool isSelectionMode = notifications.any((item) => item.isSelected);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(onPressed: (){
                   Navigator.pop(context);
                    },
                        icon: Icon(Icons.arrow_back_ios, size: 24.sp)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppText.NotifTitle, style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500, fontSize: 18.sp
                          ),),
                          SizedBox(height: 5.h),
                          Text('${notifications.length}${AppText.NotifCountSuffix}', 
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                            fontSize: 14.sp, fontWeight: FontWeight.w400,
                          ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 23.h,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10.r)),
                        backgroundColor: (isDeleteMode || isSelectionMode) ? AppColors.red : AppColors.white,
                        minimumSize: Size(55.w, 32.h),
                      ),
                      onPressed: () {
                        if (isSelectionMode) {
                          setState(() {
                            if (!isDeleteMode) {
                              isDeleteMode = true; // First click: Turn red/Confirm state
                            } else {
                              _handleAnimatedDelete(notificationVM); // Second click: Delete
                              isDeleteMode = false;
                            }
                          });
                        }
                      },
                      child: Text(
                        isDeleteMode ? AppText.NotifConfirm : AppText.NotifDelete,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,fontWeight: FontWeight.w400,
                          color: (isDeleteMode || isSelectionMode) ? AppColors.white : AppColors.red
                      ),),
                    ),
                    SizedBox(width: 18.w,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10.r)),
                        backgroundColor: isSelectionMode ? AppColors.primaryBlue : AppColors.white,
                        minimumSize: Size(60.w, 32.h),
                      ),
                      onPressed: () {
                        setState(() {
                          bool allSelected = notifications.every((item) => item.isSelected);
                          notificationVM.selectAll(!allSelected);
                        });
                      },

                      child: Text(AppText.NotifSelectAll,style: GoogleFonts.poppins(
                          fontSize: 14.sp,fontWeight: FontWeight.w400,color: isSelectionMode ? AppColors.white : AppColors.primaryBlue,
                      ),),
                    ),
                  ],
                ),
                Expanded(
                  child: CustomSmartRefresher(
                    onRefresh: () => notificationVM.fetchNotifications(),
                    child: notificationVM.isLoading
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 180.h),
                              Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                                ),
                              ),
                            ],
                          )
                        : notifications.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: 180.h),
                                  Center(
                                    child: Text(AppText.NoNotifications,
                                        style: GoogleFonts.poppins(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.grey)),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                      final notification = notifications[index];

                      return GestureDetector(
                        onTap: () {
                          notificationVM.toggleSelection(index);
                        },
                        child: OrderNotification(
                          notification.title,
                          notification.time,
                          notification.orderId,
                          notification.isSelected,
                          isSelectionMode,
                        ),
                      );
                    },
                  ),
                ),


                )
              ],
            ),
          )),
    );
  }

  Widget OrderNotification(
      String title,
      String time,
      String orderId,
      bool isSelected,
      bool isSelectionMode,
      ){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: isSelected  ? AppColors.notifSelectedRed : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black12,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSelectionMode)
            Padding(
              padding: EdgeInsets.only(right: 10.w, top: 10.h),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 24.h,
                width: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.red : AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    height: 24.h,
                    width: 24.w,
                    decoration:  BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.red : AppColors.white,
                    ),
                  ),
                )
                    : null,
              ),
            ),

          /// 🔹 Icon Circle
          Container(
            height: 40.w, width: 40.w,
            decoration: BoxDecoration(
              color:  AppColors.notifBadgeBlue, // light blue circle
              shape: BoxShape.circle,
            ),
            child: Image.asset(AppImages.iconPackage,height: 15.h,width: 15.w,)
          ),

          SizedBox(width: 14.w),

          /// 🔹 Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Title + Time Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      time,       ///order time
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: AppColors.notifTimeBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6),

                /// Order ID
                Text(
                  orderId,       ////Orderid
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,fontWeight: FontWeight.w400,
                    color: AppColors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
