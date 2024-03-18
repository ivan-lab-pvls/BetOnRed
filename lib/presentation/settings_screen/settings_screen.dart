import 'package:betonred/core/app_export.dart';
import 'package:betonred/widgets/app_bar/custom_app_bar.dart';
import 'package:betonred/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../widgets/custom_icon_button.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  static Widget builder(BuildContext context) {
    return SettingsScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 80,
        centerTitle: true,
        title: Text(
          'Settings',
          style: CustomTextStyles.titleMediumMedium,
        ),
        leadingWidth: 65,
        leading: Padding(
          padding: EdgeInsets.only(
            left: 10.h,
          ),
          child: Container(
            child: CustomIconButton(
              decoration: AppDecoration.buttonDecoration,
              onTap: () {
                NavigatorService.goBack();
              },
              height: 50,
              width: 50,
              child: Icon(
                Icons.arrow_back,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: AppDecoration.gradientMain,
        padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 40.v),
        child: Column(
          children: [
            InkWell(
                onTap: () {
                  print('123');
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => const RateAppScreen(
                              gax:
                                  'https://docs.google.com/document/d/1U3lPzTdOjwuccNAupdbPsnXyiLsWNphuAHRLF1GL1ks/edit?usp=sharing',
                            )),
                  );
                },
                child: Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width * .9,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color.fromARGB(255, 36, 216, 150)),
                  child: Center(
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )),
            SizedBox(
              height: 15.v,
            ),
            InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => const RateAppScreen(
                              gax:
                                  'https://docs.google.com/document/d/1i_qjTIHW-6u6Yjzpou6VeHiXHda5oXiORxZDamwStp4/edit?usp=sharing',
                            )),
                  );
                },
                child: Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width * .9,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color.fromARGB(255, 36, 216, 150)),
                  child: Center(
                    child: Text(
                      'Terms of Use',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )),
            SizedBox(
              height: 15.v,
            ),
            InkWell(
                onTap: () {
                  InAppReview.instance
                      .openStoreListing(appStoreId: '6478407216');
                },
                child: Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width * .9,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color.fromARGB(255, 36, 216, 150)),
                  child: Center(
                    child: Text(
                      'Rate app',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class RateAppScreen extends StatelessWidget {
  final String gax;

  const RateAppScreen({Key? key, required this.gax}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 36, 216, 150),
      ),
      body: SafeArea(
        bottom: false,
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(gax)),
        ),
      ),
    );
  }
}
