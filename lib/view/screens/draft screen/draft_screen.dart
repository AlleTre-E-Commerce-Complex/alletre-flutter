import 'package:alletre_app/utils/routes/main_stack.dart';
import 'package:alletre_app/view/screens/auction%20screen/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/controller/helpers/auction_service.dart';
import 'package:alletre_app/view/widgets/draft widgets/draft_card.dart';

class DraftsPage extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onDelete;

  const DraftsPage({super.key, required this.user, this.onDelete});

  Future<void> _handleDelete(BuildContext context, AuctionItem draft, VoidCallback refreshCallback) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Draft'),
        content: const Text('Are you sure you want to delete this draft? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: errorColor)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await AuctionService().deleteDraft(draft.id.toString());
      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Draft deleted successfully')),
          );
          // Call the refresh callback to update the UI
          refreshCallback();
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete draft')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text('My Drafts', style: TextStyle(color: secondaryColor, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainStack()),
            (Route<dynamic> route) => false,
          ),
        ),
      ),
      body: StatefulBuilder(
        builder: (context, setState) {
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Trigger rebuild
              await AuctionService().fetchDrafts();
            },
            child: FutureBuilder<List<AuctionItem>>(
              future: AuctionService().fetchDrafts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading drafts: ${snapshot.error}',
                      style: const TextStyle(color: errorColor),
                    ),
                  );
                }

                final drafts = snapshot.data ?? [];
                
                if (drafts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No drafts found',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // Sort drafts by createdAt in descending order (newest first)
                drafts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 18, bottom: 12),
                    child: Column(
                      children: List.generate(drafts.length, (index) {
                        return Column(
                          children: [
                            DraftAuctionCard(
                              auction: drafts[index],
                              cardWidth: MediaQuery.of(context).size.width * 0.95,
                              onContinue: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(draftAuction: drafts[index])
                                  ),
                                );
                              },
                              onDelete: () => _handleDelete(context, drafts[index], () => setState(() {})),
                            ),
                            if (index != drafts.length - 1)
                              const SizedBox(height: 20),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}