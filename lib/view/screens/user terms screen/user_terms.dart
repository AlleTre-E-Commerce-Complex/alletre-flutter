// import 'package:alletre_app/utils/themes/app_theme.dart';
// import 'package:flutter/material.dart';

// class TermsAndConditions extends StatelessWidget {
//   const TermsAndConditions({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Terms and Conditions'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             const Text(
//               'ALLE TRE E-COMMERCE COMPLEX LLC OPC',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18.0,
//               ),
//             ),
//             const SizedBox(height: 10.0),
//             const Text(
//               'We welcome you to the "ALLE TRE" platform, where we provide electronic auction services. By using the platform, you agree to be bound by the terms and conditions and wish them below. Please read these fine print, as your use of the platform constitutes full acceptance of these terms. If you do not agree, please refrain from using the platform.',
//               style: TextStyle(fontSize: 16.0),
//             ),
//             const SizedBox(height: 20.0),
//             _buildSectionTitle('1 - Definitions'),
//             _buildSectionContent(
//               context,
//               'The platform: The site of the ALLE TRE E-COMMERCE COMPLEX LLC OPC.\n\n'
//               'Personal data: Any information or data related personally to the user and includes, but is not limited to (name - nationality - gender - age - job title - address - phone number - email - payment card numbers - financial data - purchases, participation in previous auctions, etc.).\n\n'
//               'Auction service: The process of accessing the electronic application or website to create an auction or to view the exhibits.\n\n'
//               'Exhibit/Exhibits: Means all the goods on the website of ALLE TRE E-COMMERCE COMPLEX LLC OPC and the electronic application offered for sale and bidding on, for example, smart phones, and electronic devices.',
//             ),
//             _buildSectionTitle('2 - Registration'),
//             _buildSectionContent(
//               context,
//               'By using this site, you acknowledge that you are of legal age to enter into binding contracts and are not a person barred from receiving services under the laws of the United Arab Emirates or other competent laws. You also agree to provide true, accurate, current, and complete information about yourself as prompted by the registration form on the site.',
//             ),
//             _buildSectionTitle('3 - Service Description'),
//             _buildSectionContent(
//               context,
//               'The "ALLE TRE" platform is an electronic market that provides users with the ability to participate in auctions for electronic products. The platform provides users with opportunities to buy and sell products in a safe and easy-to-use manner.',
//             ),
//             _buildSectionTitle('4 - License and Limited Use'),
//             _buildSectionContent(
//               context,
//               '"ALLE TRE" grants you a limited license to use the platform for personal purposes. You may not: \n\n'
//               '• Copy or publish content without permission. \n'
//               '• Use malicious software that aims to negatively affect the performance of the platform.',
//             ),
//             _buildSectionTitle('5 - Content Provided'),
//             _buildSectionContent(
//               context,
//               'The content you provide on the platform remains your property, but you grant "ALLE TRE" a non-exclusive global license to use this content within the framework of providing the service. "ALLE TRE" reserves the right to remove or modify any content that violates the laws or policies of the platform.',
//             ),
//             _buildSectionTitle('6 - Disclaimer'),
//             _buildSectionContent(
//               context,
//               'The role of the platform "ALLE TRE" acts as an intermediary to facilitate auction operations between sellers and bidders. The platform is not a party to the transactions, and is not responsible for the quality or authenticity of the products offered. \n\n'
//               'Limited Liability: The platform is not responsible for: \n'
//               '• Any misleading or inaccurate information provided by sellers. \n'
//               '• Any problems related to payment or financial transfer operations. \n'
//               '• Damages resulting from using the platform or participating in auctions. \n'
//               '• Indirect or consequential damages resulting from breach.',
//             ),
//             _buildSectionTitle('7 - Harm to the Company'),
//             _buildSectionContent(
//               context,
//               'Pledge not to hack: You must not use any hacking or piracy programs to access the site or application, and adhere to the laws related to information technology, including Federal Decree-Law No. 5 of 2012 and its amendments. \n\n'
//               'Not to affect the infrastructure: You must not carry out any activity that negatively affects the infrastructure of the site or application, or prevent users from accessing it.',
//             ),
//             _buildSectionTitle('8 - Guarantees'),
//             _buildSectionContent(
//               context,
//               'No guarantees provided: ALLE TRE Company does not provide any guarantees for the items offered in the auction and acts as an intermediary to display the goods only. The buyer is responsible for verifying the item and its conformity to the specifications. \n\n'
//               'No responsibility for the information provided: The company is not responsible for any statements, specifications or information provided by the seller. \n\n'
//               'Bidder\'s responsibility: The bidder or buyer is solely responsible for reviewing all data and information related to the condition of the item before bidding or purchasing.',
//             ),
//             _buildSectionTitle('9 - Insurance'),
//             _buildSectionContent(
//               context,
//               'Insurance payment method: Both the seller and the bidder must pay the insurance amount in the manner specified by the platform, such as: credit card, cash, or check. \n\n'
//               'Insurance percentage: The insurance amount is displayed with each offer separately. \n\n'
//               'Procedures related to the insurance amount: \n'
//               '• Confiscation of the insurance amount: \n'
//               '• For the seller: If there are no bidders, the insurance amount will be refunded in full. If there are bidders, the insurance amount will be confiscated in full and the highest bidder will be compensated with 30% of the insurance amount, and the rest of the amount will go to the platform. \n'
//               '• For the bidder or buyer: In the event that the bidder does not comply with paying the auction fees, the insurance amount will be confiscated and the seller will be compensated with 50% of the insurance amount, and the rest will go to the platform.',
//             ),
//             _buildSectionTitle('10 - Compensation'),
//             _buildSectionContent(
//               context,
//               'By accepting these terms, you agree to compensate ALLE TRE for any claims or lawsuits arising as a result of your violation of the terms or your violation of any law or third-party rights.',
//             ),
//             _buildSectionTitle('11 - External Links'),
//             _buildSectionContent(
//               context,
//               'The platform may contain links to external sites. ALLE TRE is not responsible for the content of these links or any damages that may result from their use.',
//             ),
//             _buildSectionTitle(
//                 '12 - Protection of Intellectual Property Rights'),
//             _buildSectionContent(
//               context,
//               'ALLE TRE respects intellectual property rights. Please contact us if you have a complaint regarding intellectual property rights infringement on the platform.',
//             ),
//             _buildSectionTitle('13 - Laws and Jurisdiction'),
//             _buildSectionContent(
//               context,
//               'These terms and conditions are subject to and construed in accordance with the laws of the United Arab Emirates. This country is considered the legal seat for resolving disputes.',
//             ),
//             _buildSectionTitle('14 - Amendments and Notifications'),
//             _buildSectionContent(
//               context,
//               'ALLE TRE reserves the right to amend the terms and conditions at any time. You will be notified of the amendments via email or via a notice on the site, and your continued use of the site constitutes acceptance of the new terms.',
//             ),
//             _buildSectionTitle('15 - Termination of Service'),
//             _buildSectionContent(
//               context,
//               'ALLE TRE reserves the right to suspend or terminate users\' accounts in the event that they violate any of the terms and conditions, or in the event that they behave in a manner that is harmful to the platform or other users.',
//             ),
//             _buildSectionTitle('16 - Electronic Communication'),
//             _buildSectionContent(
//               context,
//               'By using the platform, you agree to receive notices from ALLE TRE via email or via notices on the site. Any notice issued by ALLE TRE shall be considered an official notice.',
//             ),
//             _buildSectionTitle('17 - Headquarters'),
//             _buildSectionContent(
//               context,
//               'ALLE TRE is one of the properties of ALLE TRE E-COMMERCE COMPLEX LLC OPC.',
//             ),
//             _buildSectionTitle('18 - Inquiries'),
//             _buildSectionContent(
//               context,
//               'In the event of any questions or inquiries regarding these terms and conditions, please contact us via email [About Technical Support and Customer Service] under the title Inquiries about the terms and conditions.',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 16.0,
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionContent(BuildContext context, String content) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10.0),
//       child: Text(
//         content,
//         style: Theme.of(context)
//             .textTheme
//             .bodyMedium
//             ?.copyWith(fontWeight: FontWeight.bold, color: onSecondaryColor),
//       ),
//     );
//   }
// }


import 'package:alletre_app/view/widgets/user%20terms%20widgets/user_terms_header.dart';
import 'package:alletre_app/view/widgets/user%20terms%20widgets/user_terms_introduction.dart';
import 'package:alletre_app/view/widgets/user%20terms%20widgets/user_terms_section.dart';
import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            HeaderText(),
            IntroductoryText(),
            SectionWidget(
              title: '1 - Definitions',
              content: 'The platform: The site of the ALLE TRE E-COMMERCE COMPLEX LLC OPC.\n\n'
                  'Personal data: Any information or data related personally to the user and includes, but is not limited to (name - nationality - gender - age - job title - address - phone number - email - payment card numbers - financial data - purchases, participation in previous auctions, etc.).\n\n'
                  'Auction service: The process of accessing the electronic application or website to create an auction or to view the exhibits.\n\n'
                  'Exhibit/Exhibits: Means all the goods on the website of ALLE TRE E-COMMERCE COMPLEX LLC OPC and the electronic application offered for sale and bidding on, for example, smart phones, and electronic devices.',
            ),
            SectionWidget(
              title: '2 - Registration',
              content: 'By using this site, you acknowledge that you are of legal age to enter into binding contracts and are not a person barred from receiving services under the laws of the United Arab Emirates or other competent laws. You also agree to provide true, accurate, current, and complete information about yourself as prompted by the registration form on the site.',
            ),
            SectionWidget(
              title: '3 - Service Description',
              content: 'The "ALLE TRE" platform is an electronic market that provides users with the ability to participate in auctions for electronic products. The platform provides users with opportunities to buy and sell products in a safe and easy-to-use manner.',
            ),
            SectionWidget(
              title: '4 - License and Limited Use',
              content: '"ALLE TRE" grants you a limited license to use the platform for personal purposes. You may not:\n\n'
                  '• Copy or publish content without permission.\n'
                  '• Use malicious software that aims to negatively affect the performance of the platform.',
            ),
            SectionWidget(
              title: '5 - Content Provided',
              content: 'The content you provide on the platform remains your property, but you grant "ALLE TRE" a non-exclusive global license to use this content within the framework of providing the service. "ALLE TRE" reserves the right to remove or modify any content that violates the laws or policies of the platform.',
            ),
            SectionWidget(
              title: '6 - Disclaimer',
              content: 'The role of the platform "ALLE TRE" acts as an intermediary to facilitate auction operations between sellers and bidders. The platform is not a party to the transactions, and is not responsible for the quality or authenticity of the products offered.\n\n'
                  'Limited Liability: The platform is not responsible for:\n'
                  '• Any misleading or inaccurate information provided by sellers.\n'
                  '• Any problems related to payment or financial transfer operations.\n'
                  '• Damages resulting from using the platform or participating in auctions.\n'
                  '• Indirect or consequential damages resulting from breach.',
            ),
            SectionWidget(
              title: '7 - Harm to the Company',
              content: 'Pledge not to hack: You must not use any hacking or piracy programs to access the site or application, and adhere to the laws related to information technology, including Federal Decree-Law No. 5 of 2012 and its amendments.\n\n'
                  'Not to affect the infrastructure: You must not carry out any activity that negatively affects the infrastructure of the site or application, or prevent users from accessing it.',
            ),
            SectionWidget(
              title: '8 - Guarantees',
              content: 'No guarantees provided: ALLE TRE Company does not provide any guarantees for the items offered in the auction and acts as an intermediary to display the goods only. The buyer is responsible for verifying the item and its conformity to the specifications.\n\n'
                  'No responsibility for the information provided: The company is not responsible for any statements, specifications or information provided by the seller.\n\n'
                  'Bidder\'s responsibility: The bidder or buyer is solely responsible for reviewing all data and information related to the condition of the item before bidding or purchasing.',
            ),
            SectionWidget(
              title: '9 - Insurance',
              content: 'Insurance payment method: Both the seller and the bidder must pay the insurance amount in the manner specified by the platform, such as: credit card, cash, or check.\n\n'
                  'Insurance percentage: The insurance amount is displayed with each offer separately.\n\n'
                  'Procedures related to the insurance amount:\n'
                  '• Confiscation of the insurance amount:\n'
                  '• For the seller: If there are no bidders, the insurance amount will be refunded in full. If there are bidders, the insurance amount will be confiscated in full and the highest bidder will be compensated with 30% of the insurance amount, and the rest of the amount will go to the platform.\n'
                  '• For the bidder or buyer: In the event that the bidder does not comply with paying the auction fees, the insurance amount will be confiscated and the seller will be compensated with 50% of the insurance amount, and the rest will go to the platform.',
            ),
            SectionWidget(
              title: '10 - Compensation',
              content: 'By accepting these terms, you agree to compensate ALLE TRE for any claims or lawsuits arising as a result of your violation of the terms or your violation of any law or third-party rights.',
            ),
            SectionWidget(
              title: '11 - External Links',
              content: 'The platform may contain links to external sites. ALLE TRE is not responsible for the content of these links or any damages that may result from their use.',
            ),
            SectionWidget(
              title: '12 - Protection of Intellectual Property Rights',
              content: 'ALLE TRE respects intellectual property rights. Please contact us if you have a complaint regarding intellectual property rights infringement on the platform.',
            ),
            SectionWidget(
              title: '13 - Laws and Jurisdiction',
              content: 'These terms and conditions are subject to and construed in accordance with the laws of the United Arab Emirates. This country is considered the legal seat for resolving disputes.',
            ),
            SectionWidget(
              title: '14 - Amendments and Notifications',
              content: 'ALLE TRE reserves the right to amend the terms and conditions at any time. You will be notified of the amendments via email or via a notice on the site, and your continued use of the site constitutes acceptance of the new terms.',
            ),
            SectionWidget(
              title: '15 - Termination of Service',
              content: 'ALLE TRE reserves the right to suspend or terminate users\' accounts in the event that they violate any of the terms and conditions, or in the event that they behave in a manner that is harmful to the platform or other users.',
            ),
            SectionWidget(
              title: '16 - Electronic Communication',
              content: 'By using the platform, you agree to receive notices from ALLE TRE via email or via notices on the site. Any notice issued by ALLE TRE shall be considered an official notice.',
            ),
            SectionWidget(
              title: '17 - Headquarters',
              content: 'ALLE TRE is one of the properties of ALLE TRE E-COMMERCE COMPLEX LLC OPC.',
            ),
            SectionWidget(
              title: '18 - Inquiries',
              content: 'In the event of any questions or inquiries regarding these terms and conditions, please contact us via email [About Technical Support and Customer Service] under the title Inquiries about the terms and conditions.',
            ),
          ],
        ),
      ),
    );
  }
}