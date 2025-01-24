import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImageFromGallery() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
  return pickedFile != null ? File(pickedFile.path) : null;
}

Future<void> pickMultipleImages(ValueNotifier<List<File>> media) async {
  try {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage(
      imageQuality: 80,
    );

    // Ensure the total images do not exceed 5
    final List<File> newFiles = pickedFiles
        .map((pickedFile) => File(pickedFile.path))
        .toList()
        .take(5 - media.value.length)
        .toList();

    media.value = [...media.value, ...newFiles];
    } catch (e) {
    debugPrint('Error picking images: $e');
  }
}
