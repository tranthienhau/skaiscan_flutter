import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:skaiscan/all_file/all_file.dart';
import 'package:skaiscan/core/app_config.dart';
import 'package:skaiscan/core/routes/routes_mapper.dart';
import 'package:skaiscan/core/theme_provider.dart';
import 'package:skaiscan/pages/loading/bloc/application_bloc.dart';
import 'package:skaiscan/pages/loading/ui/loading_page.dart';
import 'package:skaiscan_localizations/skaiscan_localizations.dart';

class _MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> {
  final _applicationBloc = ApplicationBloc();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ApplicationBloc>.value(value: _applicationBloc),
      ],
      child: OverlaySupport.global(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Skaiscan',
          theme: ThemeProvider.getTheme(isDarkMode: false),
          darkTheme: ThemeData.light(),
          themeMode: AppOptions.of(context)!.themeMode,
          home: const LoadingPage(),
          locale: AppOptions.of(context)!.locale,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onGenerateRoute: (RouteSettings settings) =>
              RoutesMapper.onGenerateRoute(settings),
          routes: RoutesMapper.buildRoute(),
          navigatorKey: App.navigationKey,
        ),
      ),
    );
  }
}

class SkaiscanApp extends StatelessWidget {
  const SkaiscanApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ModelBinding(
      initialModel: AppOptions(
        textScaleFactor: -1,
        themeMode: GetIt.I<AppConfig>().themeMode,
        locale: GetIt.I<AppConfig>().locale,
      ),
      child: Builder(builder: (context) {
        return _MyApp();
      }),
    );
  }
}
