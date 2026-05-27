import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/order_viewmodel.dart';

class CameraCaptureScreen extends StatefulWidget {
  final String orderId;

  const CameraCaptureScreen({super.key, required this.orderId});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _cameraController;
  List<XFile> _capturedPhotos = [];
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        setState(() {
          _errorMessage = 'Camera permission is required to capture photos.';
          _isInitializing = false;
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No camera found on this device.';
          _isInitializing = false;
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to open camera. Please allow camera access and try again.';
        _isInitializing = false;
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isCapturing) {
      return;
    }
    setState(() => _isCapturing = true);
    try {
      final photo = await _cameraController!.takePicture();
      if (photo.path.trim().isEmpty) {
        throw Exception('Captured photo path is invalid.');
      }
      
      HapticFeedback.mediumImpact();
      
      if (mounted) {
        _capturedPhotos.add(photo);
        setState(() {});
      }
    } catch (e) {
      AppToast.showError(title: 'Capture failed', message: e.toString());
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Widget _buildThumbnail(XFile photo) {
    final trimmedPath = photo.path.trim();
    if (trimmedPath.isEmpty) {
      return _buildImagePlaceholder(width: 110.w, height: 100.h);
    }

    final file = File(trimmedPath);
    if (!file.existsSync()) {
      return _buildImagePlaceholder(width: 110.w, height: 100.h);
    }

    return Image.file(
      file,
      width: 110.w,
      height: 100.h,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(width: 110.w, height: 100.h),
    );
  }

  Widget _buildImagePlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.lightBackground,
      child: Center(
        child: Icon(Icons.photo, size: 28.sp, color: AppColors.grey),
      ),
    );
  }

  Future<void> _uploadPhotos() async {
    if (_capturedPhotos.isEmpty || _isUploading) return;
    setState(() => _isUploading = true);
    try {
      final orderVM = context.read<OrderViewModel>();
      await orderVM.addOrderImages(
        widget.orderId,
        _capturedPhotos.map((file) => file.path).toList(),
      );
      if (!mounted) return;
      AppToast.showSuccess(title: 'Uploaded', message: 'Photos sent successfully.');
      Navigator.pop(context, true);
    } catch (e) {
      AppToast.showError(title: 'Upload failed', message: e.toString());
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview (Full Screen)
          Positioned.fill(
            child: _buildCameraContent(),
          ),

          // 2. Top Header (Back Button & Count)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: 40.h, left: 10.w, right: 20.w, bottom: 20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  if (_capturedPhotos.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${_capturedPhotos.length} ${AppText.SelectedSuffix}',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. Bottom Controls Section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(bottom: 30.h, top: 20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Thumbnail list
                  if (_capturedPhotos.isNotEmpty)
                    SizedBox(
                      height: 80.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: _capturedPhotos.length,
                        separatorBuilder: (context, index) => SizedBox(width: 10.w),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: _buildThumbnail(_capturedPhotos[index]),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => setState(() => _capturedPhotos.removeAt(index)),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  
                  SizedBox(height: 25.h),

                  // Main Action Buttons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Side - Empty/Gallery Placeholder
                        SizedBox(width: 50.w, height: 50.w),

                        // Center - Classic Shutter Button
                        GestureDetector(
                          onTap: (_isInitializing || _isCapturing || _cameraController == null) ? null : _capturePhoto,
                          child: Container(
                            height: 75.r,
                            width: 75.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Center(
                              child: _isCapturing
                                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  : Container(
                                      height: 60.r,
                                      width: 60.r,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        // Right Side - Tick/Upload Button
                        SizedBox(
                          width: 50.w,
                          height: 50.w,
                          child: _capturedPhotos.isNotEmpty
                              ? FloatingActionButton(
                                  elevation: 0,
                                  backgroundColor: AppColors.green,
                                  onPressed: _isUploading ? null : _uploadPhotos,
                                  child: _isUploading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Icon(Icons.check, color: Colors.white, size: 30),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraContent() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, size: 70.sp, color: AppColors.grey),
              SizedBox(height: 18.h),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16.sp, color: AppColors.textDark),
              ),
              SizedBox(height: 22.h),
              ElevatedButton(
                onPressed: _initializeCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  'Retry permission',
                  style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: Text('Camera not available.', style: TextStyle(color: Colors.white)));
    }

    return Center(
      child: CameraPreview(_cameraController!),
    );
  }
}
