import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImagePickerEditProfile extends StatelessWidget {
  const ImagePickerEditProfile({
    super.key,
    required this.imageFile,
    required this.currentPhotoURL,
    required this.onImagePicked,
  });

  final dynamic imageFile;
  final String? currentPhotoURL;
  final Function(dynamic) onImagePicked;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    if (kIsWeb) {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onImagePicked(image); // Pass XFile langsung untuk web
      }
    } else {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onImagePicked(File(image.path)); // Convert ke File untuk mobile
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: Theme.of(context).cardColor,
          child: ClipOval(
            child: SizedBox(
              width: 160,
              height: 160,
              child: _buildImage(context),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              onPressed: _pickImage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    if (imageFile != null) {
      if (kIsWeb) {
        // For web using image_picker_for_web
        return Image.network(
          imageFile.path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person,
            size: 80,
            color: Theme.of(context).iconTheme.color,
          ),
        );
      } else {
        // For mobile platforms
        return Image.file(imageFile as File, fit: BoxFit.cover);
      }
    } else if (currentPhotoURL != null) {
      return Image.network(
        currentPhotoURL!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.person,
          size: 80,
          color: Theme.of(context).iconTheme.color,
        ),
      );
    } else {
      return Icon(
        Icons.person,
        size: 80,
        color: Theme.of(context).iconTheme.color,
      );
    }
  }
}
