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

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
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
        ),
        if (images.length > 1)
          Container(
            height: 60,
            margin: const EdgeInsets.only(top: 8),
            child: ValueListenableBuilder<int>(
              valueListenable: _currentPage,
              builder: (context, currentPage, child) {
                return Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (index) => GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: currentPage == index 
                                  ? Theme.of(context).primaryColor
                                  : const Color.fromARGB(255, 37, 27, 27),
                                width: currentPage == index ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: _isSvg(images[index])
                                ? SvgPicture.network(
                                    images[index],
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    images[index],
                                    fit: BoxFit.cover,
                                  ),
                            ),
                          ),
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
  }
}
