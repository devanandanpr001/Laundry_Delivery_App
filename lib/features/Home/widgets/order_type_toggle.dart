import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';

class OrderTypeToggle extends StatefulWidget {
  final Function(int) onToggle;
  const OrderTypeToggle({super.key, required this.onToggle});

  @override
  State<OrderTypeToggle> createState() => _OrderTypeToggleState();
}

class _OrderTypeToggleState extends State<OrderTypeToggle> {
  int _selectedIndex = 0; // 0 for Pick Up, 1 for Delivery

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 334.w,
      height: 47.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black12,
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Selection Indicator (Active Box)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: 4.h,
            left: _selectedIndex == 0 ? 4.w : 179.w, // 179 = 334 - 151 - 4
            child: Container(
              width: 151.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFF002F96),
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x9E000000), // #0000009E
                    blurRadius: 4,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
          // Labels
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = 0);
                    widget.onToggle(0);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      "Pick Up",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: _selectedIndex == 0 ? FontWeight.w600 : FontWeight.w400,
                        color: _selectedIndex == 0 ? const Color(0xFFFFFFFF) : const Color(0xFF717171),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                    widget.onToggle(1);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      "Delivery",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: _selectedIndex == 1 ? FontWeight.w600 : FontWeight.w400,
                        color: _selectedIndex == 1 ? const Color(0xFFFFFFFF) : const Color(0xFF717171),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}