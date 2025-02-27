import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'image_placeholder.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> images;
  final Function(int)? onImageTap;

  ImageCarousel({
    super.key,
    required this.images,
    this.onImageTap,
  });

  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  bool _isSvg(String url) {
    return url.toLowerCase().endsWith('.svg');
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const PlaceholderImage();
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            _currentPage.value = index;
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onImageTap?.call(index),
              child: _isSvg(images[index])
                  ? SvgPicture.network(
                      images[index],
                      fit: BoxFit.contain,
                    )
                  : Image.network(
                      images[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const PlaceholderImage();
                      },
                    ),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: _currentPage,
              builder: (context, currentPage, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPage == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
