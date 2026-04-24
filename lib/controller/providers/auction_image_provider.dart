import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuctionImageProvider extends ChangeNotifier {
  final List<File> _mediaList = [];
  int? _coverPhotoIndex;

  List<File> get mediaList => _mediaList;
  int? get coverPhotoIndex => _coverPhotoIndex;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _mediaList.add(File(pickedFile.path));
      notifyListeners();
    }
  }

  void replaceImage(int index, File newImage) {
    _mediaList[index] = newImage;
    notifyListeners();
  }

  void removeImage(int index) {
    _mediaList.removeAt(index);
    if (_coverPhotoIndex == index) {
      _coverPhotoIndex = null;
    }
    notifyListeners();
  }

  void setCoverPhoto(int index) {
    final File selectedCover = _mediaList.removeAt(index);
    _mediaList.insert(0, selectedCover);
    _coverPhotoIndex = 0;
    notifyListeners();
  }
}
