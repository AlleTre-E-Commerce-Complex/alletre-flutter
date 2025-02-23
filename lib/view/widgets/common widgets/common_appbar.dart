import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/home%20screen/home_contents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class CommonAppBar extends StatelessWidget {
  const CommonAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return SliverAppBar(
      pinned: false, // Keeps it off-screen when scrolling down
      floating: true, // Makes it appear only when scrolling up
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: secondaryColor, size: 22),
        onPressed: () {
          userProvider.resetCheckboxes();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreenContent()));
                  },
      ),
      title: SizedBox(
        width: 210,
        height: 31,
        child: SvgPicture.asset(
          'assets/images/alletre_header.svg',
        ),
      ),
    );
  }
}
