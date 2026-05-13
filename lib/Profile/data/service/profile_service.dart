import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';
import 'package:http_parser/http_parser.dart'; // Import MediaType
import 'package:ziya_laundry_deliveryapp/core/dio_client.dart';

class ProfileService {
  final DioClient _dioClient = DioClient();

  Future<Map<String, dynamic>> fetchProfileData() async {
    try {
      final response = await _dioClient.get(ApiConstants.profile);

      // Extracting from 'user' key as per the backend response logs
      if (response != null &&
          response['success'] == true &&
          response['user'] != null) {
        final userData = Map<String, dynamic>.from(response['user']);

        // Ensure the profile image is a full URL if it's a relative path
        String? pImg = userData['profileImage']?.toString();
        if (pImg != null && pImg.isNotEmpty && !pImg.startsWith('http')) {
          userData['profileImage'] = '${ApiConstants.mediaBaseUrl}$pImg';
        } else if (pImg == null || pImg.isEmpty) {
          // If explicitly null from server, ensure it's an empty string for UI logic
          userData['profileImage'] = "";
        }

        return userData;
      }
      throw Exception(
        "Failed to parse profile: 'user' key missing in response",
      );
    } catch (e) {
      debugPrint("ProfileService Fetch Error: $e");
      rethrow;
    }
  }

  Future<String> uploadProfileImage(File image) async {
    try {
      final String fileName = image.path.split(RegExp(r'[/\\]')).last;
      final String fileExtension = fileName.split('.').last.toLowerCase();

      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
          contentType: MediaType(
            'image',
            fileExtension == 'png' ? 'png' : 'jpeg',
          ),
        ),
      });

      final response = await _dioClient.post(
        ApiConstants.profileImage,
        data: formData,
      );

      if (response != null && response['success'] == true) {
        // Check root level 'profileImage' as seen in logs, then fallbacks
        String? rawUrl =
            response['profileImage'] ??
            response['imageUrl'] ??
            response['user']?['profileImage'];

        if (rawUrl != null && rawUrl.isNotEmpty) {
          if (!rawUrl.startsWith('http')) {
            return '${ApiConstants.mediaBaseUrl}$rawUrl';
          }
          return rawUrl;
        }
      }
      return ""; // Return empty if server doesn't provide URL; re-fetch will handle it
    } catch (e) {
      debugPrint("Profile Image Upload Error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchCmsPage(String type) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.cmsPage.replaceAll(':type', type.toUpperCase()),
      );

      if (response != null && response['success'] == true && response['data'] != null) {
        return Map<String, dynamic>.from(response['data']);
      }
      return null;
    } catch (e) {
      debugPrint("CMS Page Fetch Error: $e");
      return null;
    }
  }
}
