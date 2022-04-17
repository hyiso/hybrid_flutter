## Introduction

Flutter Hybrid stack Manager.

This plugin can be used in both Flutter Module and Flutter App.

This plugin support sharing single `FlutterEngine` in `FlutterFragment` or `FlutterViewController`

Also, you can switch to multi-engine mode.


## Getting Started

More feature usage can be found in example.

#### Add dependency
In you `pubsepc.yaml`:

```
hybrid_flutter: ^0.1.0
```

#### In Dart
Use `HybridApp` instead of `WidgetsApp`、`MaterialApp` or `CupertinoApp` in your `app.dart`.

``` dart
Map<String, WidgetBuilder> get pages => {
  '/': (ctx) => Container(),
  '/home': (ctx) => HomePage(),
  '/share': (ctx) => SharePage(),
  '/spawn': (ctx) => SpawnPage(),
};

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
```

#### In Android
First, implement `IHybridFlutterNavigator` interface

``` kotlin
object HybridFlutterNavigator : IHybridFlutterNavigator {
  override fun push(route: String, arguments: HashMap<String, String>?, context: Context) {
    val intent = Intent(context, MainFragmentActivity::class.java)
    intent.putExtra(MainFragmentActivity.KEY_ROUTE, route)
    arguments?.keys?.forEach { key ->
      intent.putExtra(key, arguments[key])
    }
    context.startActivity(intent)
  }

  override fun pop(activity: Activity?, result: Any?) {
    activity?.finish()
  }
}
```

Then, set the navigator to `HybridFlutterManager` before enter `FlutterEngine`

``` kotlin
HybridFlutterManager.navigator = HybridFlutterNavigator
```

Finally, use `HybridFlutterFragment` instead of `FlutterFragment` in `FragmentActivity`.

``` kotlin
val flutterFragment = FlutterFragment.NewEngineFragmentBuilder(HybridFlutterFragment::class.java)
    .initialRoute(route)
    .build()
supportFragmentManager
    .beginTransaction()
    .add(R.id.fragment_container, flutterFragment, TAG_FLUTTER_FRAGMENT)
    .commit()
```

#### In iOS
First, implement `HybridFlutterNavigator` protocol.

``` swift
class MyHybridFlutterNavigator : NSObject, HybridFlutterNavigator {
  func pushRoute(_ route: String?, arguments: Any?, viewController flutterViewController: FlutterViewController?) {
    let vc = MyFlutterViewController.init(route: route, parameters: arguments as? [String:String], useNewEngine: false)
    flutterViewController?.navigationController?.pushViewController(vc, animated: true)
  }
  
  func pop(_ flutterViewController: FlutterViewController?, result: Any?) {
    flutterViewController?.navigationController?.popViewController(animated: true)
  }
}
```

Then, set the navigator to `HybridFlutterManager` before enter `FlutterEngine`.

``` swift
HybridFlutterManager.sharedInstance().navigator = MyHybridFlutterNavigator.init()
```

Finally, use `HybridFlutterViewController` instead of `FlutterViewController`.
``` swift
let win = UIWindow.init(frame: UIScreen.main.bounds)
let flutterViewController = MyFlutterViewController.init(route: "/home", parameters: nil, useNewEngine: false)
let navigationController = UINavigationController.init(rootViewController: flutterViewController)
navigationController.navigationBar.isHidden = true
win.rootViewController = navigationController
```