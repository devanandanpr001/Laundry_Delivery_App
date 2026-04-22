import 'dart:io';
import 'package:ziya_laundry_deliveryapp/Profile/data/models/profile_model.dart';
import '../service/profile_service.dart';

class ProfileRepository {
  final ProfileService _service;

  ProfileRepository(this._service);

  Future<ProfileModel> getProfile() async {
    final data = await _service.fetchProfileData();
    return ProfileModel.fromJson(data);
  }

  Future<String> updateProfileImage(File image) async {
    return await _service.uploadProfileImage(image);
  }
}