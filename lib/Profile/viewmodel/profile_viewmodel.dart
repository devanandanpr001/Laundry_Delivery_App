import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/Profile/data/models/profile_model.dart';
import '../data/repository/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileRepository _repository;
  ProfileModel? _userProfile;
  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileViewModel(this._repository) {
    // Use a post-frame callback or check if data exists to avoid rebuild loops in ProxyProvider
    Future.microtask(() => loadProfile());
  }

  void updateRepository(ProfileRepository repository) {
    _repository = repository;
  }

  ProfileModel? get userProfile => _userProfile;
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    if (_isLoading || _userProfile != null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _userProfile = await _repository.getProfile();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadProfileImage() async {
    if (_selectedImage == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newImageUrl = await _repository.updateProfileImage(_selectedImage!);
      
      // Update local model with new URL after successful backend upload
      if (_userProfile != null) {
        _userProfile = ProfileModel(
          name: _userProfile!.name,
          phone: _userProfile!.phone,
          profileImageUrl: newImageUrl,
        );
      }
      _selectedImage = null; // Clear selection after successful upload
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPickedImage(File img) {
    _selectedImage = img;
    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }
}