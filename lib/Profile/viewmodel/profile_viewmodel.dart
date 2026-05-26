import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/api_constants.dart';
import 'package:ziya_laundry_deliveryapp/Profile/data/repository/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository; // Fixed: Removed _init() call from constructor
  ProfileViewModel(this._repository);

  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userProfile; // Holds the fetched profile data

  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading; // This getter was already present
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userProfile => _userProfile;

  // Getter for the profile image URL from the fetched profile data
  String get profileImageUrl {
    String url = _userProfile?['profileImage']?.toString() ?? '';
    // Handle relative paths by prepending the media base URL from ApiConstants
    if (url.isNotEmpty && !url.startsWith('http')) {
      url = '${ApiConstants.mediaBaseUrl}${url.startsWith('/') ? url.substring(1) : url}';
    }
    return url;
  }

  // Getter for user name (example)
  String get userName => _userProfile?['name']?.toString() ?? 'User'; // This getter was already present

  // Getter for user phone number (example)
  String get userPhone => _userProfile?['phone']?.toString() ?? '0000000000';

  /// Clears all cached data when session expires
  void clearAllCachedData() {
    _userProfile = null;
    _selectedImage = null;
    notifyListeners();
  }

  void setPickedImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  // Method to fetch profile data from the repository
  Future<void> fetchProfileData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _userProfile = await _repository.getProfile(); // Call repository method
      _errorMessage = null;
    } catch (e) {
      // This will now capture "Server error" from your backend response
      _errorMessage = e.toString();
      debugPrint("ProfileViewModel: Error fetching profile data: $_errorMessage");
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
      final newUrl = await _repository.updateProfileImage(_selectedImage!);

      // Optimistic update: If the server returned a URL, update local state immediately
      if (newUrl.isNotEmpty) {
        if (_userProfile != null) {
          final updatedProfile = Map<String, dynamic>.from(_userProfile!);
          updatedProfile['profileImage'] = newUrl;
          _userProfile = updatedProfile;
        }
        notifyListeners();
      }

      // Re-fetch to synchronize everything else (name, etc)
      await fetchProfileData();
      
      // CRITICAL: Only clear the local preview if the VM now has a valid network URL
      // This prevents reverting to dummy if the fetch is slow or returned null
      if (profileImageUrl.isNotEmpty) {
        _selectedImage = null;
      } else {
        debugPrint("Warning: Fetch returned empty image after upload. Keeping local preview.");
        // We keep _selectedImage so the user still sees their new photo locally
      }
      
      _errorMessage = null; // Clear any previous error
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("ProfileViewModel: Error uploading profile image: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // You might want a method to clear the selected image if the user cancels the upload
  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  // You might also want a method to clear the error message after it's displayed
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  // Method to fetch CMS page content
  Future<Map<String, dynamic>?> fetchCmsPage(String type) async {
    // Removed _isLoading and _errorMessage updates and notifyListeners()
    // as CmsPageScreen manages its own loading state for CMS content.
    try {
      final result = await _repository.getCmsPage(type);
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("ProfileViewModel: Error fetching CMS page: $_errorMessage");
      return null;
    }
  }
}