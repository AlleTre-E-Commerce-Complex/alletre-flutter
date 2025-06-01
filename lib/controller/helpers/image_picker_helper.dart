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
      if (pickedFiles.isNotEmpty) {
        final List<File> newFiles = [];
        
        // Check file sizes and add valid files
        for (var pickedFile in pickedFiles) {
          final file = File(pickedFile.path);
          final fileSizeInMB = await file.length() / (1024 * 1024); // Convert to MB
          
          if (fileSizeInMB <= 50) {
            newFiles.add(file);
          } else {
            await showDialog(
              context: MyApp.navigatorKey.currentContext!,
              builder: (context) => AlertDialog(
                title: const Text('File Too Large'),
                content: Text('${pickedFile.name} exceeds 50MB limit'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
        
        // Calculate how many more files we can add
        final remainingSlots = 50 - media.value.length;
        if (remainingSlots > 0) {
          // Add only up to the remaining slots
          final filesToAdd = newFiles.take(remainingSlots).toList();
          media.value = [...media.value, ...filesToAdd];
        }
      }
    } else {
      // Check if we already have a video
      final hasVideo = media.value.any((file) => 
        file.path.toLowerCase().endsWith('.mp4') || 
        file.path.toLowerCase().endsWith('.mov')
      );
      
      if (hasVideo) {
        await showDialog(
          context: MyApp.navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('You can only upload 1 video'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      final XFile? pickedFile = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (pickedFile != null && media.value.length < 50) {
        final file = File(pickedFile.path);
        final fileSizeInMB = await file.length() / (1024 * 1024); // Convert to MB
        
        if (fileSizeInMB <= 50) {
          media.value = [...media.value, file];
        } else {
          await showDialog(
            context: MyApp.navigatorKey.currentContext!,
            builder: (context) => AlertDialog(
              title: const Text('File Too Large'),
              content: const Text('Video exceeds 50MB limit'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  } catch (e) {
    debugPrint('Error picking media: $e');
  }
}
