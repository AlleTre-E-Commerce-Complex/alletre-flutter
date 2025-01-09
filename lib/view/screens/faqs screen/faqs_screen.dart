import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/model/faq_model.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  final List<FaqModel> faqs = const [
    FaqModel(
      title: 'Tariffs',
      content: '''
• Website: www.alletre.com\n
• Owner: Alletre LLC, a limited liability company located in Dubai - United Arab Emirates.\n
• User: Anyone who accesses the Alletre website, whether for the purpose of viewing, selling, bidding, or buying without limitation.\n
• Bidder: Anyone who offers a commodity or service on the site, whether by way of auction or direct sale.\n
• Highest Bid: The highest bidder in the auction after the end of the offer period.\n
• Second Bid: The person with the second-highest bid in the auction after the end of the offer period.\n
• Offer Period: The period during which the bidder offers the good or service in the auction.
      ''',
    ),
    FaqModel(
      title: 'The Introduction',
      content: '''
• This user agreement is considered an agreement between any user who enters the site and the owner. Once the user enters the site, this agreement applies to them implicitly and is considered acceptance of its terms without the condition of signing.\n
• Entering the site constitutes acceptance of the aforementioned arbitration agreement and approval for the site or its representative to act as an arbitrator.\n
• All users agree that the site is not responsible for misuse by others and is considered an open market.\n
• Users must report any suspicious behavior or criminal attempts noticed to the competent authorities.
      ''',
    ),
    FaqModel(
      title: 'About The Site',
      content: '''
• The site is an interface for those who wish to surf the internet to display goods and services for auction to the highest bidder.
      ''',
    ),
    FaqModel(
      title: 'How The Site Works',
      content: '''
• The site is available for viewing to all internet users. Registration is required to bid or offer goods.\n
• Users must provide accurate information during registration.\n
• The auction process involves submitting data, paying fees, and abiding by the site's conditions.\n
• Penalties apply for non-compliance by bidders or buyers.
      ''',
    ),
    FaqModel(
      title: 'General Provisions',
      content: '''
• The site owner is not a party to contracts between buyers and sellers.\n
• Penalties are applied for non-compliance, with proceeds shared between affected parties and the owner.\n
• Fraudulent activities, including fake goods or payment cards, will result in fines and potential legal action.\n
• All transactions are in USD, and the site is not responsible for currency exchange losses.
      ''',
    ),
    FaqModel(
      title: 'Applicable Law and Jurisdiction',
      content: '''
• These terms and conditions are governed by the laws of Dubai and the UAE. Disputes will be resolved through arbitration.
      ''',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () {
            context.read<TabIndexProvider>().updateIndex(4);
          },
        ),
        title: const Text('FAQs', style: TextStyle(color: secondaryColor)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ExpansionTile(
                  title: Text(
                    faqs[index].title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 5.0, right: 16.0, bottom: 16.0),
                      child: _buildFormattedContent(faqs[index].content, context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormattedContent(String content, BuildContext context) {
    List<String> lines = content.trim().split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('•')) {
          return RichText(
            text: TextSpan(
              text: '• ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: onSecondaryColor),
              children: [
                TextSpan(
                  text: line.substring(1).trim(),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          );
        }
        return Text(
          line,
          style: Theme.of(context).textTheme.displaySmall,
        );
      }).toList(),
    );
  }
}
