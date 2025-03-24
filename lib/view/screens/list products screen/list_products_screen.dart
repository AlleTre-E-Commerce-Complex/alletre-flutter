import 'dart:io';
import 'package:alletre_app/controller/helpers/image_picker_helper.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/utils/validators/create_auction_validators.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../widgets/home widgets/categories widgets/categories_data.dart';

class ListProductsScreen extends StatelessWidget {
  const ListProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Add a ValueNotifier to track whether the form has been submitted
    final isSubmitted = ValueNotifier<bool>(false);
    final formKey = GlobalKey<FormState>();
    final itemNameController = TextEditingController();
    final categoryController = ValueNotifier<String?>(null);
    final subCategoryController = ValueNotifier<String?>(null);
    final descriptionController = TextEditingController();
    final condition = ValueNotifier<String?>(null);
    final media = ValueNotifier<List<File>>([]);
    final coverPhotoIndex =
        ValueNotifier<int?>(null); // Track selected cover photo

    // Get categories and subcategories dynamically
    final categories = CategoryData.categories;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () {
            context.read<TabIndexProvider>().updateIndex(1);
          },
        ),
        title: const Text('List Products',
            style: TextStyle(color: secondaryColor, fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Item Details",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: onSecondaryColor),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: itemNameController,
                decoration: InputDecoration(
                  labelText: "Item Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: errorColor),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: errorColor),
                  ),
                ),
                validator: CreateAuctionValidation.validateTitle,
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              ValueListenableBuilder<String?>(
                valueListenable: categoryController,
                builder: (context, selectedCategory, child) {
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: errorColor),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: errorColor),
                      ),
                    ),
                    value: selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: onSecondaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      categoryController.value = value;
                      subCategoryController.value = null; // Reset sub category
                    },
                    validator: CreateAuctionValidation.validateCategory,
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String?>(
                valueListenable: categoryController,
                builder: (context, selectedCategory, child) {
                  if (selectedCategory == null) {
                    return const SizedBox(); // No subcategory dropdown if category not selected
                  }
                  return ValueListenableBuilder<String?>(
                    valueListenable: subCategoryController,
                    builder: (context, selectedSubCategory, child) {
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Sub category",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: errorColor),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: errorColor),
                          ),
                        ),
                        value: selectedSubCategory,
                        // ignore: unnecessary_null_comparison
                        items: selectedCategory != null
                            ? CategoryData.getSubCategories(selectedCategory)
                                .map((subcategory) {
                                return DropdownMenuItem(
                                  value: subcategory,
                                  child: Text(
                                    subcategory,
                                    style: const TextStyle(
                                      color: onSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                );
                              }).toList()
                            : [],
                        onChanged: (value) {
                          subCategoryController.value = value;
                        },
                        validator: CreateAuctionValidation.validateSubCategory,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Item Description",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: errorColor),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: errorColor),
                  ),
                ),
                maxLines: 5,
                validator: CreateAuctionValidation.validateDescription,
              ),
              const SizedBox(height: 20),
              RichText(
                text: const TextSpan(
                  text: 'Add Media ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: onSecondaryColor),
                  children: [
                    TextSpan(
                      text: '(3-5 images)',
                      style: TextStyle(
                          color: greyColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder<List<File>>(
                valueListenable: media,
                builder: (context, mediaList, child) {
                  // Set the first image as the cover image if no cover photo is set
                  if (coverPhotoIndex.value == null && mediaList.isNotEmpty) {
                    coverPhotoIndex.value =
                        0; // Default to the first image as cover photo
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          // Generate a reordered media list with the cover photo (if set) first
                          final reorderedMediaList = coverPhotoIndex.value !=
                                      null &&
                                  coverPhotoIndex.value! < mediaList.length
                              ? [
                                  mediaList[coverPhotoIndex.value!],
                                  ...mediaList.where((file) =>
                                      file != mediaList[coverPhotoIndex.value!])
                                ]
                              : mediaList;

                          if (index < reorderedMediaList.length) {
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    // Open media gallery when image is tapped
                                    final File? newMedia =
                                        await pickMediaFromGallery();
                                    if (newMedia != null) {
                                      final updatedMedia = List<File>.from(
                                          mediaList)
                                        ..[index] =
                                            newMedia; // Replace the tapped image
                                      media.value = updatedMedia;
                                    }
                                  },
                                  child: Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: greyColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _buildMediaWidget(reorderedMediaList[index]),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -14,
                                  right: -14,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: errorColor,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      final updatedMedia =
                                          List<File>.from(mediaList)
                                            ..removeAt(index);
                                      media.value = updatedMedia;
                                      if (coverPhotoIndex.value == index) {
                                        coverPhotoIndex.value =
                                            null; // Reset cover photo
                                      }
                                    },
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: ValueListenableBuilder<int?>(
                                    valueListenable: coverPhotoIndex,
                                    builder:
                                        (context, selectedCoverIndex, child) {
                                      return GestureDetector(
                                        onTap: () {
                                          coverPhotoIndex.value = index;

                                          // Reorder the media list to display the cover photo first
                                          final File selectedCover =
                                              mediaList[index];
                                          final updatedMedia = [selectedCover] +
                                              mediaList
                                                  .where((file) =>
                                                      file != selectedCover)
                                                  .toList();
                                          media.value = updatedMedia;

                                          coverPhotoIndex.value =
                                              0; // Reset the index
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: selectedCoverIndex == index
                                                ? primaryColor.withAlpha(
                                                    (0.7 * 255).toInt())
                                                : Colors.black.withAlpha(
                                                    (0.5 * 255).toInt()),
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Center(
                                            child: Text(
                                              selectedCoverIndex == index
                                                  ? "Cover Photo"
                                                  : "Set as Cover",
                                              style: const TextStyle(
                                                color: secondaryColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Add image button
                            return GestureDetector(
                              onTap: () => pickMultipleMedia(media),
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(color: greyColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      color: avatarColor,
                                      size: 32,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: isSubmitted,
                        builder: (context, submitted, child) {
                          if (submitted) {
                            final mediaError =
                                CreateAuctionValidation.validateMediaSection(
                                    mediaList);
                            return mediaError != null
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 12),
                                    child: Text(
                                      mediaError,
                                      style: const TextStyle(
                                          color: errorColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Item Condition",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: onSecondaryColor,
                ),
              ),
              ValueListenableBuilder<String?>(
                valueListenable: condition,
                builder: (context, value, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: "new",
                            groupValue: value,
                            onChanged: (selected) =>
                                condition.value = selected!,
                          ),
                          const Text("New", style: radioTextStyle),
                        ],
                      ),
                      const SizedBox(width: 20), // Space between radio buttons
                      Row(
                        children: [
                          Radio<String>(
                            value: "used",
                            groupValue: value,
                            onChanged: (selected) =>
                                condition.value = selected!,
                          ),
                          const Text("Used", style: radioTextStyle),
                        ],
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: isSubmitted,
                        builder: (context, submitted, child) {
                          if (submitted && value == null) {
                            return const Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Text(
                                "Select item condition",
                                style: TextStyle(
                                    color: errorColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Set submitted to true to show validation errors
                        isSubmitted.value = true;
                        final isValid = formKey.currentState!.validate() &&
                            CreateAuctionValidation.validateMediaSection(
                                    media.value) ==
                                null &&
                            condition.value != null;

                        if (isValid) {
                          context.read<TabIndexProvider>().updateIndex(17);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 33),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text("Next",
                          style: TextStyle(color: secondaryColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaWidget(File mediaFile) {
    if (mediaFile.path.endsWith('.mp4') || mediaFile.path.endsWith('.mov')) {
      return _buildVideoPlayer(mediaFile);
    } else {
      return Image.file(
        mediaFile,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }

  Widget _buildVideoPlayer(File videoFile) {
    return FutureBuilder(
      future: _initializeVideoPlayer(videoFile),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return VideoPlayer(snapshot.data as VideoPlayerController);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<VideoPlayerController> _initializeVideoPlayer(File videoFile) async {
    final controller = VideoPlayerController.file(videoFile);
    await controller.initialize();
    return controller;
  }
}
