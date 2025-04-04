import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alletre_app/app.dart';

Future<File?> pickMediaFromGallery({bool isImage = true}) async {
  final ImagePicker picker = ImagePicker();
  XFile? pickedFile;
  if (isImage) {
    pickedFile = await picker.pickImage(source: ImageSource.gallery);
  } else {
    pickedFile = await picker.pickVideo(source: ImageSource.gallery);
  }
  return pickedFile != null ? File(pickedFile.path) : null;
}

Future<void> pickMultipleMedia(ValueNotifier<List<File>> media) async {
  try {
    final ImagePicker picker = ImagePicker();
    
    // Show dialog to choose between image and video
    final mediaType = await showDialog<String>(
      context: MyApp.navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Select Media Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Images'),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Videos'),
              onTap: () => Navigator.pop(context, 'video'),
            ),
          ],
        ),
      ),
    );

    if (mediaType == null) return;

    if (mediaType == 'image') {
      final List<XFile> pickedFiles = await picker.pickMultiImage(imageQuality: 80);
      final List<File> newFiles = pickedFiles
          .map((pickedFile) => File(pickedFile.path))
          .toList()
          .take(5 - media.value.length)
          .toList();
      media.value = [...media.value, ...newFiles];
    } else {
      final XFile? videoFile = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5), // Limit video duration to 5 minutes
      );
      if (videoFile != null && media.value.length < 5) {
        media.value = [...media.value, File(videoFile.path)];
      }
    }
  } catch (e) {
    debugPrint('Error picking media: $e');
  }
}
