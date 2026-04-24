import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/utils/routes/main_stack.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/common_appbar.dart';
import 'package:alletre_app/view/widgets/login%20widgets/login_buttons.dart';
import 'package:alletre_app/view/widgets/login%20widgets/login_form_fields.dart';
import 'package:alletre_app/view/widgets/login%20widgets/login_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final bool fromAuctionCreation;

  LoginPage({super.key, this.fromAuctionCreation = false});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
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
            SliverAppBar(
              pinned: false, // Keeps it off-screen when scrolling down
              floating: true, // Makes it appear only when scrolling up
              backgroundColor: primaryColor,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10,bottom: 10,top: 10),
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: SvgPicture.asset(
                    'assets/icons/app-icon.svg',
                  ),
                ),
              ),
              centerTitle: true,
              title: const Text('Login',style: TextStyle(color: Colors.white),),
            ),
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
                    Consumer<TabIndexProvider>(
                      builder: (context, tabIndexProvider, _) {
                        return LoginButtons(
                          formKey: formKey,
                          onLoginSuccess: () {
                            if (fromAuctionCreation) {
                              // If we came from auction creation, go back there
                              Navigator.pop(context);
                            } else {
                              // Reset tab index to 0 (Home) and go to home screen
                              tabIndexProvider.updateIndex(0);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainStack(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            }
                          },
                        );
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
