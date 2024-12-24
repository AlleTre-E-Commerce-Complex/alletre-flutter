import 'package:alletre_app/view/widgets/common%20widgets/common_appbar.dart';
import 'package:alletre_app/view/widgets/login%20widgets/login_buttons.dart';
import 'package:alletre_app/view/widgets/login%20widgets/login_form_fields.dart';
import 'package:alletre_app/view/widgets/login%20widgets/login_title.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  LoginFormFields(),
                  const SizedBox(height: 24),
                  const LoginButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
