import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/View/LogIn_screen.dart';
import 'package:ziya_laundry_deliveryapp/core/widgets/app_network_image.dart';

class Onboardingscreen extends StatefulWidget {
  const Onboardingscreen({super.key});

  @override
  State<Onboardingscreen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  void _next() {
    if (_currentIndex < 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: '/login'),
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _controller,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);

            },
            children: [
              _imagePage("https://www.shutterstock.com/image-photo/drycleaning-delivery-courier-giving-dress-600nw-2439026981.jpg"),
              _imagePage('https://media.istockphoto.com/id/2158161980/photo/smiling-woman-receiving-clean-clothes-on-a-hanger-in-a-plastic-bag-from-a-delivery-man-at-the.jpg?s=612x612&w=0&k=20&c=N3tZ4-qvsmWkS1DwIr_Sh5V7JzgjvIzrPxdotIing-c='),
            ],
          ),
          Positioned(
            top: 50.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icons/laundry_logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Juggle Laundry',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),

          Positioned(
            bottom: 30.h,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _next,
                child: Container(
                  width: 150.w,
                  height: 50.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.w,
                    ),
                  ),
                  child: Text(
                    _currentIndex == 1 ? 'Next' : 'Next',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF002F96),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePage(String ntwrk) {
    return SizedBox.expand(
      child: AppNetworkImage(
        imageUrl: ntwrk,
        fit: BoxFit.cover,
        placeholder: const Center(child: CircularProgressIndicator()),
        errorWidget: Container(color: Colors.black12),
      ),
    );
  }
}
