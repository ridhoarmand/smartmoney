// edit_profile_service.dart
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage({
    required dynamic imageFile,
    required String uid,
    required bool isWeb,
  }) async {
    try {
      final storageRef =
          _storage.ref().child('profile_pictures').child('$uid.jpg');

      final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': 'profile_pictures/$uid.jpg'});

      if (isWeb) {
        if (imageFile is XFile) {
          final bytes = await imageFile.readAsBytes();
          await storageRef.putData(bytes, metadata);
        }
      } else {
        await storageRef.putFile(imageFile as File, metadata);
      }

      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}
