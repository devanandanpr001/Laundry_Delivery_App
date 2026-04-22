import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/Home/viewmodel/home_viewmodel.dart';

class GalleryScreen extends StatefulWidget {
  final String orderId;
  final bool isReadOnly;

  const GalleryScreen({super.key, required this.orderId, this.isReadOnly = false});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final Set<int> _selectedIndices = {};

  void _deleteSelectedImages() {
    final homeVM = context.read<HomeViewModel>();
    // Sort indices descending to avoid index shifting issues while deleting
    List<int> sortedIndices = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
    
    for (int index in sortedIndices) {
      homeVM.removeOrderImage(widget.orderId, index);
    }
    
    setState(() => _selectedIndices.clear());
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Optimized: Only listen to the pickedImages list for this specific order
    final images = context.select<HomeViewModel, List<String>>(
      (vm) => vm.orders.firstWhere((o) => o.orderId == widget.orderId).pickedImages
    );

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
                        Container(
                          width: 116.75.w,
                          height: 151.13.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            image: DecorationImage(
                              image: _getImageProvider(images[index]),
                              fit: BoxFit.cover,
                            ),
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
