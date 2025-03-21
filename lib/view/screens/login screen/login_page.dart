import 'package:alletre_app/utils/routes/main_stack.dart';
import 'package:alletre_app/view/widgets/common%20widgets/common_appbar.dart';
import 'package:alletre_app/view/widgets/login%20widgets/login_buttons.dart';
import 'package:alletre_app/view/widgets/login%20widgets/login_form_fields.dart';
import 'package:alletre_app/view/widgets/login%20widgets/login_title.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final bool fromAuctionCreation;

  LoginPage({super.key, this.fromAuctionCreation = false});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (fromAuctionCreation) {
          // If we came from auction creation and user presses back,
          // we should go back to the auction details screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainStack(),
            ),
            (Route<dynamic> route) => false,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const CommonAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LoginTitle(),
                    const SizedBox(height: 24),
                    LoginFormFields(formKey: formKey),
                    const SizedBox(height: 24),
                    LoginButtons(
                      formKey: formKey,
                      onLoginSuccess: () {
                        if (fromAuctionCreation) {
                          // If we came from auction creation, go back there
                          Navigator.pop(context);
                        } else {
                          // Otherwise go to home screen
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainStack(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
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
}
