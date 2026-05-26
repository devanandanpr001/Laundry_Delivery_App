import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Profile/viewmodel/profile_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/BottomNavigation/CustomSmartRefresher.dart';

class CmsPageScreen extends StatefulWidget {
  final String type; // 'PRIVACY', 'TERMS', 'ABOUT', 'FAQ'
  final String title;

  const CmsPageScreen({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  State<CmsPageScreen> createState() => _CmsPageScreenState();
}

class _CmsPageScreenState extends State<CmsPageScreen> {
  Map<String, dynamic>? _cmsData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCmsPage();
  }

  Future<void> _fetchCmsPage() async {
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    final data = await profileVM.fetchCmsPage(widget.type);
    setState(() {
      _cmsData = data;
      _isLoading = false;
      _errorMessage = data == null ? 'Failed to load ${widget.title.toLowerCase()}' : null;
    });
  }

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
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios, size: 20.sp),
                  ),
                  Expanded(
                    child: Text(
                      _cmsData?['title'] ?? widget.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      ),
                    )
                  : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 60.sp,
                              color: AppColors.grey.withValues(alpha: 0.5),
                            ),
                            SizedBox(height: 15.h),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton(
                              onPressed: _fetchCmsPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                              ),
                              child: Text(
                                'Retry',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : CustomSmartRefresher(
                        onRefresh: _fetchCmsPage,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_cmsData?['content'] != null)
                              Padding(
                                padding: EdgeInsets.only(top: 20.h),
                                child: Text(
                                  _cmsData!['content'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            if (_cmsData?['faq'] != null && _cmsData!['faq'].isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 20.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'FAQ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      _cmsData!['faq'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
              )
              )
            ],
          ),
        ),
      ),
    );
  }
}