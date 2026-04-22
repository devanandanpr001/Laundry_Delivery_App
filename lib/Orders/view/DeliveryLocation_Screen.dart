import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import '../../Constants/app_colors.dart';

class DeliveryLocationScreen extends StatefulWidget {
  const DeliveryLocationScreen({super.key});

  @override
  State<DeliveryLocationScreen> createState() => _DeliveryLocationScreenState();
}

class _DeliveryLocationScreenState extends State<DeliveryLocationScreen> {
  bool showDeliveryDestination = false;

  final MapController _mapController = MapController();

  final LatLng destination = LatLng(10.1076, 76.3516);       // Aluva
  final LatLng pickup = LatLng(10.0872, 76.3327);  // Muppathadam

  void goToDestination() {
    _mapController.move(destination, 15);

    setState(() {
      showDeliveryDestination = true;
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

                onTap: (tapPosition, point){
                  goToDestination();
                }
            ),

            children: [

              /// MAP TILE
              TileLayer(
                urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName:
                'com.example.ziya_laundry_deliveryapp',
              ),

              /// POLYLINE ROUTE
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      pickup,
                      LatLng(10.0802, 76.3320),
                      destination,
                    ],
                    color: AppColors.linkBlue,
                    strokeWidth: 4,
                  )
                ],
              ),

              /// MARKERS
              MarkerLayer(
                markers: [

                  Marker(
                    point: pickup,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.linkBlue,
                      size: 40,
                    ),
                  ),

                  Marker(
                    point: destination,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.navigation,
                      color: AppColors.linkBlue,
                      size: 40,
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
              padding: const EdgeInsets.only(
                  top: 50, left: 20, right: 16, bottom: 16),
              color: AppColors.white,
              child: Row(
                children: [

                  const Icon(Icons.arrow_back_ios_new_rounded),

                  const SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
                      Text(
                        AppText.titleDelivery,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        AppText.subtitlePickUp,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: AppColors.grey
                        ),
                      ),
                    ],
                  )
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.deliveryCardBg,
                borderRadius: BorderRadius.circular(20),
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

                  const SizedBox(height: 16),

                  Row(
                    children: [

                      Container(
                        height: 50.h,width: 50.w,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryBlue,width: 4)
                        ),
                        child:  Padding(
                          padding: const EdgeInsets.all(4),
                          child: GestureDetector(
                            onTap: (){
                              if (showDeliveryDestination){
                                Navigator.pop(context,true);
                              }
                              else{
                                Navigator.pop(context,false);
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: AppColors.primaryBlue,
                              child: Icon(Icons.close, color: AppColors.white),
                            ),
                          ),
                        ),
                      ),

                      showDeliveryDestination ? SizedBox(width: 15.w,) : SizedBox(width: 60.w,),

                      showDeliveryDestination ?
                      Text(AppText.ArrivedMsgD,style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),)
                          :
                      Column(
                        children:  [
                          Text(
                            AppText.DeliveryTimeValue,
                            style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
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

                  const SizedBox(height: 16),

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
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.call_outlined,),
                                SizedBox(width: 3.w,),
                                Text(
                                  AppText.CustPhoneValue,
                                  style: TextStyle(color: AppColors.grey),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 29.h,width: 78.w,
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text(AppText.Call),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}