import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:in_app_update/in_app_update.dart';

class AppUpdateService {

  /// ANDROID PLAY STORE UPDATE
  static Future<void> checkAndroidUpdate() async {

    try {

      /// Android only
      if (!Platform.isAndroid) return;

      final AppUpdateInfo updateInfo =
          await InAppUpdate.checkForUpdate();

      debugPrint(
        "Update Availability: ${updateInfo.updateAvailability}",
      );

      /// UPDATE AVAILABLE
      if (updateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable) {

        /// FORCE UPDATE
        if (updateInfo.immediateUpdateAllowed) {

          await InAppUpdate.performImmediateUpdate();

          return;
        }

        /// FLEXIBLE UPDATE
        if (updateInfo.flexibleUpdateAllowed) {

          await InAppUpdate.startFlexibleUpdate();

          await InAppUpdate.completeFlexibleUpdate();

          return;
        }
      }

    } catch (e) {

      debugPrint(
        "Android Update Error: $e",
      );
    }
  }
}