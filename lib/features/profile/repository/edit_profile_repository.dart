import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/edit_profile_service.dart';

class EditProfileRepository extends StateNotifier<bool> {
  EditProfileRepository(this.ref) : super(false);

  final Ref ref;
  final _service = EditProfileService();

  Future<void> updateProfile({
    required User user,
    required String name,
    required String email,
    required String currentPassword,
    required String newPassword,
    required bool changeEmail,
    required bool changePassword,
    required File? imageFile,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    state = true; // Start loading

    try {
      if (imageFile != null) {
        final photoURL = await _service.uploadImage(imageFile, user.uid);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
      }

      if (name != user.displayName) {
        await user.updateDisplayName(name);
      }

      if (changeEmail && email != user.email) {
        await _service.updateUserEmail(user, email, currentPassword);
      }

      if (changePassword) {
        await _service.updateUserPassword(user, currentPassword, newPassword);
      }

      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = false; // End loading
    }
  }
}
