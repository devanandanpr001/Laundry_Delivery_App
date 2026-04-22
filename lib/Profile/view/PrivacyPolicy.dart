import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';

class Privacypolicy extends StatelessWidget {
  const Privacypolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: AppColors.bg,
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(onPressed: (){
                      Navigator.pop(context);
                    },
                      icon: Icon(Icons.arrow_back_ios, size: 20.sp),),
                    Text('Privacy Policy',style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500
                    ),)
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Maintext('DELIVERY STAFF TERMS & CONDITIONS', FontWeight.w700),
                        Maintext('SLAMS WASH', FontWeight.w400),
                        Maintext('These Terms & Conditions apply to all \nDelivery Staff employed by SLAMS WASH.', FontWeight.w400),
                        Maintext('By accepting employment, the employee \nagrees to comply with the following rules and\n responsibilities.', FontWeight.w400),
                        Maintext('1. Employment Status', FontWeight.w700),
                        Maintext('The Delivery Boy is a direct employee of SLAMS WASH.', FontWeight.w400),
                        Maintext('The employee must follow company policies and instructions.', FontWeight.w400),
                        Maintext('Employment may be full-time / part-time as agreed.', FontWeight.w400),
                        Maintext('2. Duties & Responsibilities', FontWeight.w700),
                        Maintext('The employee agrees to:', FontWeight.w400),
                        Maintext('Pick up and deliver laundry items safely and on time', FontWeight.w400),
                        Maintext('Handle customer garments carefully', FontWeight.w400),
                        Maintext('Maintain polite and professional behavior', FontWeight.w400),
                        Maintext('Wear company uniform (if provided)', FontWeight.w400),
                        Maintext('Follow assigned routes and schedules', FontWeight.w400),
                        Maintext('Maintain cleanliness of vehicle and equipment', FontWeight.w400),
                        Maintext('3. Working Hours', FontWeight.w700),
                        Maintext('Working hours will be as per company schedule.', FontWeight.w400),
                        Maintext('Overtime (if any) will be according to company policy.', FontWeight.w400),
                        Maintext('Repeated late reporting may lead to disciplinary action.', FontWeight.w400),
                        Maintext('4. Company Property', FontWeight.w700),
                        Maintext('Any company vehicle, bag, device, or uniform provided must be used responsibly.', FontWeight.w400),
                        Maintext('Damages due to negligence may be recovered from salary.', FontWeight.w400),
                        Maintext('Company property must be returned upon resignation or termination.', FontWeight.w400),
                        Maintext('5. Customer Conduct', FontWeight.w700),
                        Maintext('The employee must:', FontWeight.w400),
                        Maintext('Not argue with customers', FontWeight.w400),
                        Maintext('Not misuse customer information', FontWeight.w400),
                        Maintext('Not accept unauthorized payments', FontWeight.w400),
                        Maintext('Not behave inappropriately', FontWeight.w400),
                        Maintext('Customer complaints may result in warning or termination.', FontWeight.w400),
                        Maintext('6. Salary & Payments', FontWeight.w700),
                        Maintext('Salary will be paid as per agreed amount.', FontWeight.w400),
                        Maintext('Incentives (if applicable) will be based on performance.', FontWeight.w400),
                        Maintext('Deductions may apply for damages, misconduct, or policy violations.', FontWeight.w400),
                        Maintext('7. Prohibited Activities', FontWeight.w700),
                        Maintext('The employee must not:', FontWeight.w400),
                        Maintext('Steal or misuse customer items', FontWeight.w400),
                        Maintext('Deliver prohibited or illegal goods', FontWeight.w400),
                        Maintext('Work under the influence of alcohol or drugs', FontWeight.w400),
                        Maintext('Share company confidential information', FontWeight.w400),
                        Maintext('Violation may result in immediate termination and legal action.', FontWeight.w400),
                        Maintext('8. Safety & Compliance', FontWeight.w700),
                        Maintext('The employee must follow all traffic rules.', FontWeight.w400),
                        Maintext('The company is not responsible for fines due to personal violations.', FontWeight.w400),
                        Maintext('Accidents must be reported immediately.', FontWeight.w400),
                        Maintext('9. Leave & Absence', FontWeight.w700),
                        Maintext('Leave must be informed in advance.', FontWeight.w400),
                        Maintext('Emergency leave should be communicated immediately.', FontWeight.w400),
                        Maintext('Unauthorized absence may result in salary deduction.', FontWeight.w400),
                        Maintext('10. Termination', FontWeight.w700),
                        Maintext('SLAMS WASH reserves the right to terminate employment if:', FontWeight.w400),
                        Maintext('Company policies are violated', FontWeight.w400),
                        Maintext('Misconduct is proven', FontWeight.w400),
                        Maintext('Repeated complaints are received', FontWeight.w400),
                        Maintext('Performance is unsatisfactory', FontWeight.w400),
                        Maintext('11. Policy Updates', FontWeight.w700),
                        Maintext('SLAMS WASH may update these terms as required. Employees must comply with revised policies.', FontWeight.w400),
                        SizedBox(height: 40.h,)
                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  Widget Maintext(String text, FontWeight? fontweight){
    return Padding(
      padding: EdgeInsets.all(4.r),
      child: Text(text,style: GoogleFonts.poppins(
        fontSize: 14.sp,fontWeight: fontweight
      ),),
    );
  }
}
