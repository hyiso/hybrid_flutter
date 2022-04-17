
import 'package:flutter/material.dart';
import 'package:flutter_hybrid/flutter_hybrid.dart';

import 'pages.dart';
import 'route.dart';

class MyApp extends StatefulWidget {

  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = const TextStyle(
      fontFamily: 'PingFangSC-Regular',
      fontFamilyFallback: ['PingFang SC', 'Roboto'],
      fontSize: 14,
      color: Colors.black
    );
    return HybridApp(
      textStyle: style,
      onGenerateInitialRoutes: (String initialRouteName) {
        final List<Route<dynamic>> result = <Route<dynamic>>[];
        final route = onGenerateRoute(RouteSettings(name: initialRouteName));
        if (route != null) {
          result.add(route);
        }
        return result;
      },
      onGenerateRoute: onGenerateRoute,
      color: Colors.white,
      builder: (ctx, child) {
        return Theme(
          data: ThemeData(
            textTheme: TextTheme(
              bodyText1: style,
              bodyText2: style,
            ),
            primaryTextTheme: TextTheme(
              bodyText1: style,
              bodyText2: style,
            )
          ),
          child: child!,
        );
      },
    );
  }
  
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    String? routeName = settings.name;
    Object? arguments = settings.arguments;
    final Uri? uri = Uri.tryParse(routeName ?? '/');
    if (uri != null) {
      routeName = uri.path;
      arguments ??= uri.queryParameters;
    }
    final newSettings = RouteSettings(
      name: routeName,
      arguments: arguments,
    );
    return MyRoute(
      settings: newSettings,
      builder: pages[newSettings.name] ?? (ctx) => Container(color: Colors.red)
    );
  }
}
