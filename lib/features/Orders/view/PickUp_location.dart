import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';

class PickupLocationScreen extends StatefulWidget {
  const PickupLocationScreen({super.key});

  @override
  State<PickupLocationScreen> createState() => _PickupLocationScreenState();
}

class _PickupLocationScreenState extends State<PickupLocationScreen> {
  bool showDestination = false;

  final MapController _mapController = MapController();

  final LatLng pickup = LatLng(10.1076, 76.3516); // Aluva
  final LatLng destination = LatLng(10.0872, 76.3327); // Muppathadam

  void goToDestination() {
    _mapController.move(destination, 15);

    setState(() {
      showDestination = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: pickup,
              initialZoom: 15,

              onTap: (tapPosition, point) {
                goToDestination();
              },
            ),

            children: [
              /// MAP TILE
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.ziya_laundry_deliveryapp',
              ),

              /// POLYLINE ROUTE
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [pickup, LatLng(10.0802, 76.3320), destination],
                    color: AppColors.linkBlue,
                    strokeWidth: 4.w,
                  ),
                ],
              ),

              /// MARKERS
              MarkerLayer(
                markers: [
                  Marker(
                    point: pickup,
                    width: 40.w,
                    height: 40.w,
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.linkBlue,
                      size: 40.sp,
                    ),
                  ),

                  Marker(
                    point: destination,
                    width: 40.w,
                    height: 40.w,
                    child: Icon(
                      Icons.navigation,
                      color: AppColors.linkBlue,
                      size: 40.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// TOP HEADER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 50.h,
                left: 20.w,
                right: 16.w,
                bottom: 16.h,
              ),
              color: AppColors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
                  ),

                  SizedBox(width: 10.w),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppText.titlePickup,
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        AppText.subtitlePickUp,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// BOTTOM CARD
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.deliveryCardBg,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Container(
                        height: 50.h,
                        width: 50.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlue,
                            width: 4.w,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: GestureDetector(
                            onTap: () {
                              if (showDestination) {
                                Navigator.pop(context, true);
                              } else {
                                Navigator.pop(context, false);
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: AppColors.primaryBlue,
                              child: Icon(
                                Icons.close,
                                color: AppColors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ),

                      showDestination
                          ? SizedBox(width: 15.w)
                          : SizedBox(width: 60.w),

                      showDestination
                          ? Text(
                              AppText.ArrivedMsg,
                              style: GoogleFonts.poppins(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : Column(
                              children: [
                                Text(
                                  AppText.DeliveryTimeValue,
                                  style: GoogleFonts.poppins(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  AppText.DeliveryDistValue,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.CustNameValue,
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.call_outlined, size: 18.sp),
                                SizedBox(width: 3.w),
                                Text(
                                  AppText.CustPhoneValue,
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 29.h,
                        width: 78.w,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            textStyle: TextStyle(fontSize: 12.sp),
                          ),
                          child: const Text(AppText.Call),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
