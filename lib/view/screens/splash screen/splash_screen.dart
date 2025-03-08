// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:alletre_app/controller/providers/focus_state_provider.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/utils/images/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  Future<void> _initializeNavigation() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    // Update the tab index to show the home screen
    Provider.of<TabIndexProvider>(context, listen: false).updateIndex(0);
  }

  @override
  Widget build(BuildContext context) {
    final focusState = Provider.of<FocusStateNotifier>(context);

    return GestureDetector(
      onTap: () {
        focusState.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).splashColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 230,
                width: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                ),
                child: ClipOval(
                  child: SvgPicture.asset(
                    AppImages.splash,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}