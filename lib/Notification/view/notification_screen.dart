import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
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
              createdAt: removedItem.createdAt,
              message: removedItem.message,
              isRead: removedItem.isRead, // Pass isRead
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
                                      if (isSelectionMode) {
                                        notificationVM.toggleSelection(index);
                                      } else {
                                        notificationVM.markAsReadAt(index);
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              backgroundColor: Colors.transparent,
                                              insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  NotificationItemWidget(
                                                    title: notification.title,
                                                    createdAt: notification.createdAt,
                                                    message: notification.message,
                                                    isSelected: false,
                                                    isRead: true,
                                                    isSelectionMode: false,
                                                    isExpanded: true,
                                                  ),
                                                  SizedBox(height: 10.h),
                                                  IconButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    icon: Icon(Icons.close, color: AppColors.white, size: 30.sp),
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                    onLongPress: () {
                                      if (!isSelectionMode) {
                                        setState(() {
                                          notificationVM.toggleSelection(index);
                                        });
                                      }
                                    },
                                    child: NotificationItemWidget(
                                      title: notification.title,
                                      createdAt: notification.createdAt,
                                      message: notification.message,
                                      isSelected: notification.isSelected,
                                      isRead: notification.isRead,
                                      isSelectionMode: isSelectionMode,
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
}
