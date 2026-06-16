import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/order_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/premium_dialog.dart';

class GalleryScreen extends StatefulWidget {
  final String orderId;
  final bool isReadOnly;

  const GalleryScreen({super.key, required this.orderId, this.isReadOnly = false});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final Set<int> _selectedIndices = {};

  void _deleteSelectedImages() async {
    final confirmed = await showPremiumConfirmationDialog(
      context,
      title: 'Delete Images?',
      description: 'Are you sure you want to delete the selected images?',
      confirmText: 'Yes',
      cancelText: 'No',
    );
    if (!confirmed) return;

    final orderVM = context.read<OrderViewModel>();
    List<int> sortedIndices = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
    
    try {
      for (int index in sortedIndices) {
        orderVM.removeOrderImage(widget.orderId, index);
      }
      if (mounted) {
        AppToast.showImageDeleteSuccess(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showImageDeleteFailed(context, error: "Failed to delete images");
      }
    }
    
    setState(() => _selectedIndices.clear());
  }

  bool _isLocalFileValid(String path) {
    final localPath = path.trim();
    return localPath.isNotEmpty && File(localPath).existsSync();
  }

  Widget _buildGalleryImage(String path) {
    final trimmedPath = path.trim();
    if (trimmedPath.isEmpty) {
      return _buildPlaceholderTile();
    }

    if (trimmedPath.startsWith('http')) {
      return Image.network(
        trimmedPath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.lightBackground,
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                    : null,
                color: AppColors.primaryBlue,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderTile(),
      );
    }

    if (trimmedPath.startsWith('assets/')) {
      return Image.asset(
        trimmedPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderTile(),
      );
    }

    if (_isLocalFileValid(trimmedPath)) {
      return Image.file(
        File(trimmedPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderTile(),
      );
    }

    return _buildPlaceholderTile();
  }

  Widget _buildPlaceholderTile() {
    return Container(
      color: AppColors.lightBackground,
      child: Center(
        child: Icon(Icons.photo, size: 32.sp, color: AppColors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Optimized: Only listen to the pickedImages list for this specific order
    final orderVm = context.watch<OrderViewModel>();
    final order = orderVm.orders.firstWhereOrNull((o) => o.orderId == widget.orderId);
    if (order == null) {
      return const Scaffold(body: Center(child: Text("Order not found."))); // Or a more elaborate error state
    }
    final images = order.pickedImages;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// APP BAR
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios, size: 20.sp),
                  ),
                  Text(
                    AppText.GalleryTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedIndices.isNotEmpty && !widget.isReadOnly)
                    Row(
                      children: [
                        Text(
                          '${_selectedIndices.length}${AppText.SelectedSuffix}',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        IconButton(
                          onPressed: _deleteSelectedImages,
                          icon: Icon(Icons.delete_outline, color: AppColors.red, size: 24.sp),
                        ),
                      ],
                      ),
                  
                ],
              ),
            ),

            /// GRID VIEW
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                itemCount: images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 15.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 116.74 / 151.12, // Matches your specific dimensions
                ),
                itemBuilder: (context, index) {
                  bool isSelected = _selectedIndices.contains(index);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIndices.remove(index);
                        } else {
                          _selectedIndices.add(index);
                        }
                      });
                    },
                    child: Stack(
                      children: [
                        /// MAIN IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: SizedBox(
                            width: 116.75.w,
                            height: 151.13.h,
                            child: _buildGalleryImage(images[index]),
                          ),
                        ),
                        /// SELECTION BOX (TOP RIGHT)
                        if (!widget.isReadOnly)
                          Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            width: 20.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                            color: AppColors.gallerySelectionBg,
                              borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.white, width: 1.w), // Inset shadow simulation
                            boxShadow: [
                                BoxShadow(
                                color: AppColors.black26, // #00000040
                                  blurRadius: 4,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? Icon(Icons.check,
                                    size: 14.sp, color: AppColors.primaryBlue)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
