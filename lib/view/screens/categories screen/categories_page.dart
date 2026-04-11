import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/category_state.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/category.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/services/category_service.dart';
import 'package:alletre_app/view/screens/all%20auctions%20screen/all_auctions_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';

class CategoriesPage extends StatelessWidget {
  final List<Category> categories = CategoryService.getAllCategories();

  CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Resets all the titles when the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryState>(context, listen: false).resetAllTitles();
    });

    return Scaffold(
      appBar: const NavbarElementsAppbar(appBarTitle: 'Categories', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final item = categories[index];
            return CategoryCard(
              title: item.nameEn,
              auctions: item.auctionsCount,
              listings: item.listingCount,
              imageUrl: item.bannerLink == null ? "" : item.bannerLink!,
              onTap: (type) {
                final auctionProvider = context.read<AuctionProvider>();
                String title = 'Live Auctions';
                List<AuctionItem> auctions = [];
                String placeholder = 'No live auctions at the moment.\nPlace your auction right away.';
                if (type == 'Listings') {
                  title = 'Listed Products';
                  auctions.addAll(auctionProvider.listedProducts);
                  placeholder = 'No products listed for sale.\nList your product here.';
                } else {
                  auctions.addAll(auctionProvider.liveAuctions);
                  auctions.addAll(auctionProvider.upcomingAuctions);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllAuctionsScreen(
                      title: title,
                      user: UserModel.empty(),
                      auctions: auctions,
                      placeholder: placeholder,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final int auctions;
  final int listings;
  final String imageUrl;
  final Function(String type) onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.auctions,
    required this.listings,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // TODO: Navigate to category details page
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl == "") ...{
              Expanded(
                child: Image.asset('assets/images/no_image.png'),
              ),
            } else ...{
              // Image section
              Expanded(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            },
            // Gradient section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColorDark],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Bottom row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoBox(value: '$auctions', label: 'Auctions', onTap: onTap, context: context),
                        _infoBox(value: '$listings', label: 'Listings', onTap: onTap, context: context),
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

  Widget _infoBox({String value = '', String label = '', Function(String)? onTap, BuildContext? context}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onTap!(label);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context!).textSelectionTheme.selectionColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
