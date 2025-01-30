import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/user%20terms%20widgets/user_terms_header.dart';
import 'package:alletre_app/view/widgets/user%20terms%20widgets/user_terms_introduction.dart';
import 'package:alletre_app/view/widgets/user%20terms%20widgets/user_terms_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () {
            context.read<TabIndexProvider>().updateIndex(14);
          },
        ),
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(color: secondaryColor, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const HeaderText(),
            const SizedBox(height: 4),
            const IntroductoryText(),
            SectionWidget(
              title: '1 - Definitions',
              content: Text(
                'The platform: The site of the ALLE TRE E-COMMERCE COMPLEX LLC OPC.\n\n'
                'Personal data: Any information or data related personally to the user and includes, but is not limited to (name - nationality - gender - age - job title - address - phone number - email - payment card numbers - financial data - purchases, participation in previous auctions, etc.).\n\n'
                'Auction service: The process of accessing the electronic application or website to create an auction or to view the exhibits.\n\n'
                'Exhibit/Exhibits: Means all the goods on the website of ALLE TRE E-COMMERCE COMPLEX LLC OPC and the electronic application offered for sale and bidding on, for example, smart phones, and electronic devices.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '2 - Registration',
              content: Text(
                'By using this site, you acknowledge that you are of legal age to enter into binding contracts and are not a person barred from receiving services under the laws of the United Arab Emirates or other competent laws. You also agree to provide true, accurate, current, and complete information about yourself as prompted by the registration form on the site.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '3 - Service Description',
              content: Text(
                'The "ALLE TRE" platform is an electronic market that provides users with the ability to participate in auctions for electronic products. The platform provides users with opportunities to buy and sell products in a safe and easy-to-use manner.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '4 - License and Limited Use',
              content: Text(
                '"ALLE TRE" grants you a limited license to use the platform for personal purposes. You may not:\n\n'
                '• Copy or publish content without permission.\n'
                '• Use malicious software that aims to negatively affect the performance of the platform.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '5 - Content Provided',
              content: Text(
                'The content you provide on the platform remains your property, but you grant "ALLE TRE" a non-exclusive global license to use this content within the framework of providing the service. "ALLE TRE" reserves the right to remove or modify any content that violates the laws or policies of the platform.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '6 - Disclaimer',
              content: Text(
                'The role of the platform "ALLE TRE" acts as an intermediary to facilitate auction operations between sellers and bidders. The platform is not a party to the transactions, and is not responsible for the quality or authenticity of the products offered.\n\n'
                'Limited Liability: The platform is not responsible for:\n'
                '• Any misleading or inaccurate information provided by sellers.\n'
                '• Any problems related to payment or financial transfer operations.\n'
                '• Damages resulting from using the platform or participating in auctions.\n'
                '• Indirect or consequential damages resulting from breach.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '7 - Harm to the Company',
              content: Text(
                'Pledge not to hack: You must not use any hacking or piracy programs to access the site or application, and adhere to the laws related to information technology, including Federal Decree-Law No. 5 of 2012 and its amendments.\n\n'
                'Not to affect the infrastructure: You must not carry out any activity that negatively affects the infrastructure of the site or application, or prevent users from accessing it.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            const SizedBox(height: 10),
            SectionWidget(
              content: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '8 - ',
                      style:
                          Theme.of(context).textTheme.bodyLarge, //  title style
                    ),
                    TextSpan(
                      text:
                          'The ALLE TRE E-COMMERCE COMPLEX LLC OPC platform is committed to ensuring the integrity and transparency of auctions. Therefore, it is strictly prohibited for the seller, directly or indirectly, to participate as a bidder in the auction of the product he has offered for sale, whether using his personal account or another account belonging to him or any person acting on his behalf. In the event that any attempt to circumvent this condition is discovered, the platform management reserves the right to take the necessary measures, which include canceling the auction, confiscating the insurance amount, and blocking the accounts involved in order to maintain a fair experience for all users.',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall, // content style
                    ),
                  ],
                ),
              ),
            ),
            SectionWidget(
              title: '9 - Guarantees',
              content: Text(
                'No guarantees provided: ALLE TRE Company does not provide any guarantees for the items offered in the auction and acts as an intermediary to display the goods only. The buyer is responsible for verifying the item and its conformity to the specifications.\n\n'
                'No responsibility for the information provided: The company is not responsible for any statements, specifications or information provided by the seller.\n\n'
                'Bidder\'s responsibility: The bidder or buyer is solely responsible for reviewing all data and information related to the condition of the item before bidding or purchasing.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '10 - Insurance',
              content: Text(
                'Insurance payment method: Both the seller and the bidder must pay the insurance amount in the manner specified by the platform, such as: credit card, cash, or check.\n\n'
                'Insurance percentage: The insurance amount is displayed with each offer separately.\n\n'
                'Procedures related to the insurance amount:\n'
                '• Confiscation of the insurance amount:\n'
                '• For the seller: If there are no bidders, the insurance amount will be refunded in full. If there are bidders, the insurance amount will be confiscated in full and the highest bidder will be compensated with 30% of the insurance amount, and the rest of the amount will go to the platform.\n'
                '• For the bidder or buyer: In the event that the bidder does not comply with paying the auction fees, the insurance amount will be confiscated and the seller will be compensated with 50% of the insurance amount, and the rest will go to the platform.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '11 - Compensation',
              content: Text(
                'By accepting these terms, you agree to compensate ALLE TRE for any claims or lawsuits arising as a result of your violation of the terms or your violation of any law or third-party rights.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '12 - External Links',
              content: Text(
                'The platform may contain links to external sites. ALLE TRE is not responsible for the content of these links or any damages that may result from their use.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '13 - Protection of Intellectual Property Rights',
              content: Text(
                'ALLE TRE respects intellectual property rights. Please contact us if you have a complaint regarding intellectual property rights infringement on the platform.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '14 - Laws and Jurisdiction',
              content: Text(
                'These terms and conditions are subject to and construed in accordance with the laws of the United Arab Emirates. This country is considered the legal seat for resolving disputes.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '15 - Value Added Tax Compliance',
              content: Text(
                'The ALLE TRE E-COMMERCE COMPLEX LLC OPC confirms that all transactions conducted through the platform are subject to the provisions of Federal Decree-Law No. (8) of 2017 regarding Value Added Tax and its executive regulations, if the tax registration conditions apply to the seller.\n\n'
                'Seller\'s Responsibility for Value Added Tax:\n\n'
                '• The prices offered by the seller include value added tax.\n'
                '• The ALLE TRE E-COMMERCE COMPLEX LLC OPC acts as an electronic intermediary to facilitate auctions between sellers and buyers, and the platform does not bear any legal or financial responsibility related to issuing tax invoices, collecting value added tax, or any other tax obligations of sellers.\n'
                '• The VAT registered seller must fully comply with all applicable tax laws and regulations in the United Arab Emirates, including issuing correct and complete tax invoices that include VAT when completing any sale through the platform.\n'
                '• The ALLE TRE E-COMMERCE COMPLEX LLC OPC fully disclaims any liability for any failure by the seller to meet its tax obligations, including failure to issue tax invoices or failure to collect or pay value added tax. The seller is exclusively responsible for any legal or financial consequences arising from non-compliance with tax laws and regulations within the United Arab Emirates.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '16 - Amendments and Notifications',
              content: Text(
                'ALLE TRE reserves the right to amend the terms and conditions at any time. You will be notified of the amendments via email or via a notice on the site, and your continued use of the site constitutes acceptance of the new terms.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '17 - Termination of Service',
              content: Text(
                'ALLE TRE reserves the right to suspend or terminate users\' accounts in the event that they violate any of the terms and conditions, or in the event that they behave in a manner that is harmful to the platform or other users.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '18 - Electronic Communication',
              content: Text(
                'By using the platform, you agree to receive notices from ALLE TRE via email or via notices on the site. Any notice issued by ALLE TRE shall be considered an official notice.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '19 - Headquarters',
              content: Text(
                'ALLE TRE is one of the properties of ALLE TRE E-COMMERCE COMPLEX LLC OPC.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SectionWidget(
              title: '20 - Inquiries',
              content: Text(
                'In the event of any questions or inquiries regarding these terms and conditions, please contact us via email [About Technical Support and Customer Service] under the title Inquiries about the terms and conditions.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
