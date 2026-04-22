import 'dart:io';

class ProfileService {
  // Simulate backend API calls
  Future<Map<String, dynamic>> fetchProfileData() async {
    await Future.delayed(const Duration(seconds: 1));
    return {'name': 'Rahul', 'phone': '+91 6236594528'};
  }

  Future<String> uploadProfileImage(File image) async {
    return "https://example.com/uploaded_image.jpg";
  }
}