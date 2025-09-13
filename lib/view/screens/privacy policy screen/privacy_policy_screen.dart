import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadHtmlFromAssets();
  }

  Future<void> _loadHtmlFromAssets() async {
    try {
      final htmlString = await rootBundle.loadString('assets/html/privacy_policy.html');
      await _controller.loadHtmlString(htmlString);
    } catch (e) {
      await _controller.loadHtmlString('''
        <html>
          <body>
            <h1>Error Loading Privacy Policy...</h1>
            <p>Could not load the privacy policy. Please try again later.</p>
          </body>
        </html>
      ''');
    }
  }

  @override
  void dispose() {
    _controller.clearCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavbarElementsAppbar(
        appBarTitle: 'Privacy Policy',
        showBackButton: true,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}