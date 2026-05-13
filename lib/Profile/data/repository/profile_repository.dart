import 'dart:io';
import 'package:ziya_laundry_deliveryapp/Profile/data/service/profile_service.dart';

class ProfileRepository {
  final ProfileService _profileService;

  ProfileRepository(
    this._profileService,
  ); // Constructor now accepts ProfileService

  // Method to fetch the complete profile data
  Future<Map<String, dynamic>> getProfile() async {
    return await _profileService.fetchProfileData();
  }

  // Method to upload the profile image
  Future<String> updateProfileImage(File image) async {
    return await _profileService.uploadProfileImage(image);
  }

  // Method to fetch CMS page content
  Future<Map<String, dynamic>?> getCmsPage(String type) async {
    return await _profileService.fetchCmsPage(type);
  }
}
