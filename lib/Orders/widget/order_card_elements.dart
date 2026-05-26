import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import '../data/model/Bundle_Model.dart';
import '../viewmodel/DeliveryStage.dart';
import 'package:image_picker/image_picker.dart';

/// Section displaying the Bundle management (Add/List)
class BundleSection extends StatelessWidget {
  final List<BundleModel> bundles;
  final VoidCallback onAddTap;
  final Function(int) onDelete;
  final bool isReadOnly;

  const BundleSection({
    super.key,
    required this.bundles,
    required this.onAddTap,
    required this.onDelete,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Container(
          height: 49.h,
          decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(10.w)),
          child: Padding(
            padding: EdgeInsets.only(left: 5.w),
            child: Row(
              children: [
                Image.asset(AppImages.iconBundle, height: 24.h, width: 24.w),
                SizedBox(width: 10.w),
                Text(AppText.BundleLabel, style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.primaryBlue)),
                const Spacer(),
                if (!isReadOnly) IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onAddTap),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bundles.length,
          itemBuilder: (context, index) {
            final bundle = bundles[index];
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: AppColors.bundleListBg, borderRadius: BorderRadius.circular(10.w)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(color: AppColors.cyanBlue, shape: BoxShape.circle),
                        child: Center(child: Text("${index + 1}", style: GoogleFonts.poppins(color: AppColors.white, fontSize: 11.sp, fontWeight: FontWeight.bold))),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${AppText.BundleLabel} ${index + 1}", 
                              style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textDark)
                            ),
                            Text(
                              "${bundle.weight} KG Weight",
                              style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(color: AppColors.priceBadgeBg, borderRadius: BorderRadius.circular(20.w)),
                        child: Text(
                          "₹ ${(bundle.price * (double.tryParse(bundle.weight) ?? 0)).toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                        ),
                      ),
                      if (!isReadOnly) ...[
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: () => onDelete(index),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(color: AppColors.errorRed.withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(Icons.delete_outline, color: AppColors.errorRed, size: 16.sp),
                          ),
                        ),
                      ]
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Wrap(children: bundle.services.map((s) => Text("• $s   ", style: const TextStyle(color: AppColors.primaryBlue))).toList()),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}

/// Dialog to view and pick more images
class ImagePickerDialog extends StatelessWidget {
  final List<String> pickedImages;
  final Function(List<String>) onImagesAdded;
  final Function(int) onImageRemoved;

  const ImagePickerDialog({super.key, required this.pickedImages, required this.onImagesAdded, required this.onImageRemoved});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: StatefulBuilder(
        builder: (context, setStateDialog) => Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Text(AppText.SelectedImages, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate),
                  onPressed: () async {
                    final images = await ImagePicker().pickMultiImage();
                    if (images.isNotEmpty) {
                      onImagesAdded(images.map((img) => img.path).toList());
                      setStateDialog(() {});
                    }
                  },
                )
              ]),
              SizedBox(
                height: 300.h,
                child: GridView.builder(
                  itemCount: pickedImages.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                  itemBuilder: (context, index) => Stack(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(8.w), child: _buildImage(pickedImages[index])),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          onImageRemoved(index);
                          setStateDialog(() {});
                        },
                        child: Container(decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 18, color: AppColors.white)),
                      ),
                    )
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildImage(String path, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
  final trimmedPath = path.trim();
  if (trimmedPath.isEmpty) {
    return _buildImagePlaceholder(height: height, width: width);
  }

  if (trimmedPath.startsWith('http')) {
    return Image.network(
      trimmedPath,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: width,
          color: AppColors.lightBackground,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
              color: AppColors.primaryBlue,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(height: height, width: width),
    );
  } else if (trimmedPath.startsWith('assets/')) {
    return Image.asset(
      trimmedPath,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(height: height, width: width),
    );
  }

  final file = File(trimmedPath);
  if (!file.existsSync()) {
    return _buildImagePlaceholder(height: height, width: width);
  }

  return Image.file(
    file,
    height: height,
    width: width,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(height: height, width: width),
  );
}

Widget _buildImagePlaceholder({double? height, double? width}) {
  return Container(
    height: height,
    width: width,
    color: AppColors.lightBackground,
    alignment: Alignment.center,
    child: Icon(
      Icons.broken_image_outlined,
      size: 28.sp,
      color: AppColors.grey,
    ),
  );
}

/// Section displaying and managing uploaded images
class ImageGallerySection extends StatelessWidget {
  final List<String> pickedImages;
  final VoidCallback onSeeMore;

  const ImageGallerySection({super.key, required this.pickedImages, required this.onSeeMore});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Image.asset(AppImages.iconUpload, height: 24.h, width: 24.w, color: AppColors.primaryBlue),
            SizedBox(width: 8.w),
            Text(AppText.UploadedImages, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
            const Spacer(),
            TextButton(onPressed: onSeeMore, child: Text(AppText.SeeMore, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w400, color: AppColors.primaryBlue))),
          ],
        ),
        SizedBox(
          height: 90.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pickedImages.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: ClipRRect(borderRadius: BorderRadius.circular(8.w), child: _buildImage(pickedImages[index], height: 90.h, width: 90.w)),
            ),
          ),
        ),
      ],
    );
  }
}

/// The large action button that changes based on delivery stage
class OrderProgressButton extends StatelessWidget {
  final DeliveryStage stage;
  final VoidCallback onPressed;
  final String? text;

  const OrderProgressButton({super.key, required this.stage, required this.onPressed, this.text});

  String get buttonText {
    if (text != null) return text!;
    switch (stage) {
      case DeliveryStage.startPickup: return AppText.BtnStartPickup;
      case DeliveryStage.uploadImages: return AppText.BtnCapturePhoto;
      case DeliveryStage.orderPicked: return AppText.BtnOrderPicked;
      case DeliveryStage.startDelivery: return AppText.BtnStartDeliver;
      case DeliveryStage.reachedDelivery: return AppText.ArrivedMsgD;
      default: return "";
    }
  }

  String get buttonIcon {
    if (text != null) return "";
    switch (stage) {
      case DeliveryStage.startPickup: return AppImages.iconLocation;
      case DeliveryStage.uploadImages: return AppImages.iconUpload;
      case DeliveryStage.orderPicked: return AppImages.navOrders;
      case DeliveryStage.startDelivery: return AppImages.iconLocation;
      case DeliveryStage.reachedDelivery: return AppImages.iconOrderDelivered;
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (stage == DeliveryStage.delivered) return const SizedBox.shrink();
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
        backgroundColor: AppColors.primaryBlue,
        minimumSize: Size(310.w, 32.h),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (buttonIcon.isNotEmpty) ...[
            Image.asset(buttonIcon, color: AppColors.white, height: 24.h, width: 24.w),
            SizedBox(width: 6.w),
          ],
          Text(buttonText, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w500, color: AppColors.white)),
        ],
      ),
    );
  }
}

/// Row for View and Accept buttons
class AcceptViewActionRow extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onView;
  final VoidCallback? onAccept;

  const AcceptViewActionRow({super.key, required this.isOnline, required this.onView, this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w), side: const BorderSide(color: AppColors.primaryBlue, width: 0.5)),
              minimumSize: Size(0, 32.h),
            ),
            onPressed: onView,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppImages.iconView, height: 20.h, width: 20.w),
                SizedBox(width: 4.w),
                Text(AppText.BtnView, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.primaryBlue)),
              ],
            ),
          ),
        ),
        if (isOnline) ...[
          SizedBox(width: 10.w),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
                backgroundColor: AppColors.primaryBlue,
                minimumSize: Size(0, 32.h),
              ),
              onPressed: onAccept,
              child: Text(AppText.BtnAccept, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.white)),
            ),
          ),
        ]
      ],
    );
  }
}