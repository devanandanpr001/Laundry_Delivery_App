import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/widgets/Reusable_inputfield.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/widgets/custom_button.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/viewmodel/SignUp_viewmodel.dart';

class ChangepasswordScreen extends StatefulWidget {
  const ChangepasswordScreen({super.key});

  @override
  State<ChangepasswordScreen> createState() => _ChangepasswordScreenState();
}

class _ChangepasswordScreenState extends State<ChangepasswordScreen> {
  late final TextEditingController currentController;
  late final TextEditingController newController;
  late final TextEditingController confirmController;

  @override
  void initState() {
    super.initState();
    currentController = TextEditingController();
    newController = TextEditingController();
    confirmController = TextEditingController();
  }

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios, size: 20.sp),),
                      Text(AppText.titlePass,style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500
                      ),)
                    ],
                  ),
                  SizedBox(height: 20.h,),
                  Text(AppText.MsgPass,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),),
                  SizedBox(height: 15.h,),
                  Image.asset(
                    'assets/security.png',
                    height: 200.h,
                    width: 200.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20.h),

                  InputField(
                    label: '',
                    hint: 'current password',
                    controller: currentController,
                    obscure: true,),
                  InputField(
                    label: '',
                    hint: 'new password',
                    controller: newController,
                    obscure: true,),
                  InputField(
                    label: '',
                    hint: 're-type new password',
                    controller: confirmController,
                    obscure: true,),
                  SizedBox(height: 10.h),

                  Consumer<SignupViewModel>(
                    builder: (context, vm, child) => CustomButton(
                      text: AppText.BtnPass,
                      loading: vm.isLoading,
                      onPressed: vm.isLoading ? null : () async {
                        final error = await vm.changePassword(
                          currentPassword: currentController.text,
                          newPassword: newController.text,
                          confirmPassword: confirmController.text,
                        );

                        if (!mounted) return;

                        if (error != null) {
                          AppToast.showPasswordChangedFailed(context, error: error);
                        } else {
                          AppToast.showPasswordChangedSuccess(context);
                          Navigator.pop(context);
                        }
                      },
                      backgroundColor: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                      height: 42.h,
                      borderRadius: 8.r,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
