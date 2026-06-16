// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';

// class OrderTypeToggle extends StatefulWidget {
//   final Function(int) onToggle;
//   const OrderTypeToggle({super.key, required this.onToggle});

//   @override
//   State<OrderTypeToggle> createState() => _OrderTypeToggleState();
// }

// class _OrderTypeToggleState extends State<OrderTypeToggle> {
//   int _selectedIndex = 0; // 0 for Pick Up, 1 for Delivery

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 52.h,
//       padding: EdgeInsets.all(4.r),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF0F2F5),
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//             spreadRadius: 0,
//           )
//         ],
//       ),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final tabWidth = constraints.maxWidth / 2;
//           return Stack(
//             children: [
//               AnimatedPositioned(
//                 duration: const Duration(milliseconds: 350),
//                 curve: Curves.fastLinearToSlowEaseIn,
//                 left: _selectedIndex == 0 ? 0 : tabWidth,
//                 top: 0,
//                 bottom: 0,
//                 child: Container(
//                   width: tabWidth,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF002F96), Color(0xFF001A57)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(14.r),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF002F96).withOpacity(0.4),
//                         blurRadius: 8,
//                         offset: const Offset(0, 3),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         if (_selectedIndex != 0) {
//                           setState(() => _selectedIndex = 0);
//                           widget.onToggle(0);
//                         }
//                       },
//                       behavior: HitTestBehavior.opaque,
//                       child: Center(
//                         child: AnimatedDefaultTextStyle(
//                           duration: const Duration(milliseconds: 200),
//                           style: GoogleFonts.poppins(
//                             fontSize: 16.sp,
//                             fontWeight: _selectedIndex == 0 ? FontWeight.w600 : FontWeight.w500,
//                             color: _selectedIndex == 0 ? Colors.white : const Color(0xFF717171),
//                           ),
//                           child: const Text("Pick Up"),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         if (_selectedIndex != 1) {
//                           setState(() => _selectedIndex = 1);
//                           widget.onToggle(1);
//                         }
//                       },
//                       behavior: HitTestBehavior.opaque,
//                       child: Center(
//                         child: AnimatedDefaultTextStyle(
//                           duration: const Duration(milliseconds: 200),
//                           style: GoogleFonts.poppins(
//                             fontSize: 16.sp,
//                             fontWeight: _selectedIndex == 1 ? FontWeight.w600 : FontWeight.w500,
//                             color: _selectedIndex == 1 ? Colors.white : const Color(0xFF717171),
//                           ),
//                           child: const Text("Delivery"),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';

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