import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/Home/view/HomePage.dart';
import 'package:ziya_laundry_deliveryapp/Orders/view/OrderList_Screen.dart';
import 'package:ziya_laundry_deliveryapp/Profile/view/Profile_Screen.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  final List<String> _icons = [
    AppImages.navHome,
    AppImages.navOrders,
    AppImages.navProfile,
  ];

  final List<String> _labels = [
    AppText.NavHome,
    AppText.NavOrders,
    AppText.NavProfile,
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      Homepage(
        onGoToOrders: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      OrderlistScreen(
        onBackToHome: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      ProfileScreen(
        onBackToHome: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 68.w,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10.r,
              color: AppColors.black12,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            final isSelected = _currentIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = index;
                });
              },
              child: AnimatedContainer(
                  height: 48.h, width: 67.w,
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue : AppColors.white,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        _icons[index],
                        height: 19.r, width: 17.r,
                        color: isSelected ? AppColors.white : AppColors.grey,
                      ),
                      SizedBox(height: 1.h),
                      FittedBox(
                        child: Text(
                          _labels[index],
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: isSelected ? AppColors.white : AppColors.grey,
                            fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            );
          }),
        ),
      ),
    );
  }
}
