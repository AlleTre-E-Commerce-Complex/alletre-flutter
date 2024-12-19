import 'package:alletre_app/view/widgets/search_field_widget.dart';
import 'package:alletre_app/controller/providers/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    final isQueryEmpty = searchProvider.isQueryEmpty;
    final filteredAuctions = searchProvider.filteredAuctions;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Row(
            children: [
              Expanded(
                child: SearchFieldWidget(
                  leadingIcon: Icons.arrow_back,
                  onLeadingIconPressed: () {
                    Navigator.pop(context);
                  },
                  onChanged: (query) {
                    searchProvider.updateQuery(query); // Updates search results
                  },
                  autofocus: true,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isQueryEmpty || filteredAuctions.isEmpty
            ? Center(
                child: Text(
                  'No results found',
                  style: Theme.of(context).textTheme.displayMedium!
                ),
              )
            : ListView.builder(
                itemCount: filteredAuctions.length,
                itemBuilder: (context, index) {
                  final auction = filteredAuctions[index];
                  return ListTile(
                    leading: Image.network(auction.imageUrl),
                    title: Text(auction.title),
                    subtitle: Text('Price: ${auction.price}'),
                  );
                },
              ),
      ),
    );
  }
}
