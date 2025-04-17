import 'package:alletre_app/utils/routes/main_stack.dart';
import 'package:alletre_app/view/screens/auction%20screen/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/user_model.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:alletre_app/view/widgets/auction card widgets/image_placeholder.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';

class DraftsPage extends StatelessWidget {
  final AuctionItem draftAuction;
  final UserModel user;
  final VoidCallback? onDelete;

  const DraftsPage({super.key, required this.draftAuction, required this.user, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final List<AuctionItem> draftAuctions = [draftAuction];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text('Drafts Preview', style: TextStyle(color: secondaryColor, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainStack()),
            (Route<dynamic> route) => false,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 18, bottom: 12),
          child: Column(
            children: List.generate(draftAuctions.length, (index) {
              return Column(
                children: [
                  DraftAuctionCard(
                    auction: draftAuctions[index],
                    cardWidth: MediaQuery.of(context).size.width * 0.95,
                    onContinue: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(draftAuction: draftAuctions[index])
                        ),
                      );
                    },
                    onDelete: onDelete,
                  ),
                  if (index != draftAuctions.length - 1)
                    const SizedBox(height: 10),
                ],
              );
            }),
          ),
        ),
      ),
    );
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
          foregroundColor: secondaryColor,
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
