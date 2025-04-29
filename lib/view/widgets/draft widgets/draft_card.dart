import 'dart:io';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../auction card widgets/image_placeholder.dart';

String getDisplayStatus(String status) {
  switch (status.toLowerCase()) {
    case 'new':
      return 'NEW';
    case 'used':
      return 'USED';
    case 'refurbished':
      return 'REFURBISHED';
    default:
      return status.toUpperCase();
  }
}

class DraftAuctionCard extends StatelessWidget {
  final AuctionItem auction;
  final double cardWidth;
  final VoidCallback? onContinue;
  final VoidCallback? onDelete;
  const DraftAuctionCard({
    super.key,
    required this.auction,
    required this.cardWidth,
    this.onContinue,
    this.onDelete,
  });

  bool _isSvg(String url) {
    final Uri uri = Uri.parse(url);
    return uri.path.split('.').last.toLowerCase() == 'svg';
  }

  bool _isLocalImage(String path) {
    return path.startsWith('/') || path.startsWith('file://');
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = auction.imageLinks.isNotEmpty ? auction.imageLinks.first : null;
    Widget imageWidget;

    if (imagePath == null) {
      imageWidget = const PlaceholderImage();
    } else if (_isSvg(imagePath)) {
      imageWidget = SvgPicture.network(
        imagePath,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const PlaceholderImage(),
      );
    } else if (_isLocalImage(imagePath)) {
      imageWidget = Image.file(
        File(imagePath.replaceFirst('file://', '')),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const PlaceholderImage(),
      );
    } else {
      imageWidget = Image.network(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const PlaceholderImage(),
      );
    }

    return SizedBox(
      width: cardWidth,
      height: 130,
      child: Card(
        margin: const EdgeInsets.only(right: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Container(
                width: 110,
                height: 130,
                color: avatarColor.withAlpha(56),
                child: imageWidget,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Status
                    Row(
                      children: [
                        Text(
                          auction.title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: avatarColor.withAlpha(56),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            getDisplayStatus(auction.usageStatus),
                            style: TextStyle(
                              fontSize: 6,
                              color: avatarColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Category Tags
                    Row(
                      children: [
                        _tagContainer(context, auction.categoryName),
                        const SizedBox(width: 6),
                        _tagContainer(context, auction.subCategoryName),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Full-width Buttons
                    Column(
                      children: [
                        _fullWidthButton(context, 'Continue', onContinue),
                        const SizedBox(height: 6),
                        _fullWidthButton(context, 'Delete', onDelete),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagContainer(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: avatarColor.withAlpha(56),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: onSecondaryColor,
              fontSize: 9,
            ),
      ),
    );
  }

  Widget _fullWidthButton(BuildContext context, String text, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 24,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: text == 'Delete' ? avatarColor : primaryColor,
          foregroundColor: text == 'Delete' ? Colors.black : secondaryColor,
          padding: const EdgeInsets.symmetric(vertical: 2),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(text),
      ),
    );
  }
} 