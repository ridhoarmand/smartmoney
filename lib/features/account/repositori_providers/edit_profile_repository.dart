// edit_profile_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/edit_profile_service.dart';

final editProfileRepositoryProvider =
    StateNotifierProvider<EditProfileRepository, bool>((ref) {
  return EditProfileRepository(ref);
});

class EditProfileRepository extends StateNotifier<bool> {
  EditProfileRepository(this.ref) : super(false);

  final Ref ref;
  final _service = EditProfileService();

  Future<void> updateProfile({
    required User user,
    required String name,
    required dynamic imageFile,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    state = true; // Start loading

    try {
      if (imageFile != null) {
        final photoURL = await _service.uploadImage(
            imageFile: imageFile, uid: user.uid, isWeb: kIsWeb);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
      }

      if (name != user.displayName) {
        await user.updateDisplayName(name);
      }

      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = false; // End loading
    }
  }
}
