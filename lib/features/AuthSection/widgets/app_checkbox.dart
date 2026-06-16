import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isLoginStyle;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.isLoginStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoginStyle) {
      return SizedBox(
        width: 16.w,
        height: 16.h,
        child: Transform.scale(
          scale: 16.w / 18,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0064D7),
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
            side: BorderSide(
              width: 0.5.r,
              color: Colors.black54,
            ),
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const Color(0xFF0064D7);
              }
              return Colors.transparent;
            }),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      );
    } else {
      // Signup Screen Checkbox Style
      return SizedBox(
        width: 24.w,
        height: 24.h,
        child: Transform.scale(
          scale: 24.w / 18, // Base size of compact checkbox is ~18
          child: Checkbox(
            value: value,
            activeColor: const Color(0xFF0064D7),
            onChanged: onChanged,
            side: BorderSide(
              width: 1.r,
              color: const Color(0x40000000),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      );
    }
  }
}