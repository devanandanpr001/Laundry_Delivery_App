import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/CustomSmartRefresher.dart';
import 'package:ziya_laundry_deliveryapp/core/services/SocketService.dart';
import '../viewmodel/notification_viewmodel.dart';
import '../widgets/notification_item_widget.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isDeleteMode = false;
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NotificationViewModel>().initSocket();
    });
  }

  @override
  void dispose() {
    SocketService().off('notification-change');
    super.dispose();
  }

  String _formatDate(String createdAt) {
    final parts = createdAt.split(' ');
    return parts.isNotEmpty ? parts.first : createdAt;
  }

  String _formatTime(String createdAt) {
    final parts = createdAt.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
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
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios, size: 24.sp),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppText.NotifTitle,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          '${notifications.length}${AppText.NotifCountSuffix}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 23.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10.r),
                      ),
                      backgroundColor: isSelectionMode
                          ? AppColors.red
                          : AppColors.red.withOpacity(0.35),
                      minimumSize: Size(55.w, 32.h),
                    ),
                    onPressed: isSelectionMode
                        ? () {
                            setState(() {
                              if (!isDeleteMode) {
                                isDeleteMode = true;
                                } else {
                                  notificationVM.deleteSelected().then((deletedIds) {
                                    if (deletedIds.isNotEmpty && mounted) {
                                      AppToast.showNotificationDeleted(context, onUndo: () async {
                                        await notificationVM.undoMultipleClear(deletedIds);
                                      });
                                    }
                                  });
                                  isDeleteMode = false;
                                }
                            });
                          }
                        : null,
                    child: Text(
                      isDeleteMode ? AppText.NotifConfirm : AppText.NotifDelete,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 18.w),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10.r),
                      ),
                      backgroundColor: isSelectionMode
                          ? AppColors.primaryBlue
                          : AppColors.white,
                      minimumSize: Size(60.w, 32.h),
                    ),
                    onPressed: () {
                      setState(() {
                        bool allSelected = notifications.every(
                          (item) => item.isSelected,
                        );
                        notificationVM.selectAll(!allSelected);
                      });
                    },

                    child: Text(
                      AppText.NotifSelectAll,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: isSelectionMode
                            ? AppColors.white
                            : AppColors.primaryBlue,
                      ),
                    ),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryBlue,
                                ),
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
                              child: Text(
                                AppText.NoNotifications,
                                style: GoogleFonts.poppins(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return GestureDetector(
                              onTap: () async {
                                if (isSelectionMode) {
                                  notificationVM.toggleSelection(index);
                                } else {
                                  if (!notification.isRead)
                                    await notificationVM.markAsReadAt(index);
                                  // Toggle expansion on single tap
                                  setState(() {
                                    if (!_expandedIds.contains(
                                      notification.id,
                                    )) {
                                      _expandedIds.add(notification.id);
                                    } else {
                                      _expandedIds.remove(notification.id);
                                    }
                                  });
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
                                isExpanded: _expandedIds.contains(
                                  notification.id,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
