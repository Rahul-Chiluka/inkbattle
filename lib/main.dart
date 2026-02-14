import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/services/ad_service.dart';
import 'package:toastification/toastification.dart';
import 'firebase_options.dart';
import 'constants/bloc_provider.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:inkbattle_frontend/utils/routes/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'dart:developer';
import 'package:inkbattle_frontend/services/notification_service.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env file if it exists, otherwise use default values from Environment class
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env file not found, will use default values from Environment class
    print("Warning: .env file not found, using default values");
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications (FCM + local notifications)
  await NotificationService().initialize();
  
  // Set navigator key for notification navigation
  NotificationService().setNavigatorKey(navigatorKey);

  await AdService.initializeMobileAds();
  // Load persistent banner ad (app-wide, loaded once)
  AdService.loadPersistentBannerAd();
  Bloc.observer = MyBlocObserver();
  usePathUrlStrategy();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await LocalStorageUtils.init();
  
  // Initialize app language
  final savedLanguage = LocalStorageUtils.getLanguage();
  AppLocalizations.setLanguage(savedLanguage);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

    // To remove the white edge gap at corners for the app 
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiBlocProvider(
      providers: blocProviders,
      child: const MyApp(),
    ),
  );
}

// class TestApp extends StatelessWidget {
//   const TestApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Ink Battle Test',
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Ink Battle')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text('Ink Battle App', style: TextStyle(fontSize: 24)),
//               const SizedBox(height: 20),
//               const Text('App is running successfully!'),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   print('Button pressed');
//                 },
//                 child: const Text('Test Button'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final appRoutes = Routes();

  @override
  void initState() {
    super.initState();
    // Register callback to rebuild app when language changes
    AppLocalizations.setOnLanguageChanged(() {
      if (mounted) {
        setState(() {});
      }
    });
    
    // Set router for notification navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().setRouter(appRoutes.router);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      key: ValueKey(AppLocalizations.getCurrentLanguage()), // Force complete rebuild on language change
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ToastificationWrapper(
          child: MaterialApp.router(
            key: ValueKey(AppLocalizations.getCurrentLanguage()), // Force router rebuild
            scaffoldMessengerKey: snackbarKey,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              textTheme: GoogleFonts.kumbhSansTextTheme(),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            routeInformationParser: appRoutes.router.routeInformationParser,
            routeInformationProvider: appRoutes.router.routeInformationProvider,
            routerDelegate: appRoutes.router.routerDelegate,
          ),
        );
      },
    );
  }
}

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    log("Created: $bloc");
    super.onCreate(bloc);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    log("Change in $bloc: $change");
    super.onChange(bloc, change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    log("Change in $bloc: $transition");
    super.onTransition(bloc, transition);
  }

  @override
  void onClose(BlocBase bloc) {
    log("Closed: $bloc");
    super.onClose(bloc);
  }
}
