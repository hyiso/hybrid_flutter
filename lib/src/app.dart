import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'channels.dart';
import 'navigator.dart';
import 'route.dart';

class HybridApp extends StatefulWidget {

  const HybridApp({
    Key? key,
    this.navigatorKey,
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    List<NavigatorObserver> this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.color,
    this.textStyle,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
  }) : routeInformationProvider = null,
       routeInformationParser = null,
       routerDelegate = null,
       backButtonDispatcher = null,
       super(key: key);

  const HybridApp.router({
    Key? key,
    this.routeInformationProvider,
    required RouteInformationParser<Object> this.routeInformationParser,
    required RouterDelegate<Object> this.routerDelegate,
    this.backButtonDispatcher,
    this.builder,
    this.color,
    this.textStyle,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
  }) : navigatorObservers = null,
       navigatorKey = null,
       onGenerateRoute = null,
       onGenerateInitialRoutes = null,
       onUnknownRoute = null,
       initialRoute = null,
       super(key: key);

  /// {@macro flutter.widgets.widgetsApp.navigatorKey}
  final GlobalKey<NavigatorState>? navigatorKey;

  /// {@macro flutter.widgets.widgetsApp.initialRoute}
  final String? initialRoute;

  /// {@macro flutter.widgets.widgetsApp.onGenerateRoute}
  final RouteFactory? onGenerateRoute;

  /// {@macro flutter.widgets.widgetsApp.onGenerateInitialRoutes}
  final InitialRouteListFactory? onGenerateInitialRoutes;

  /// {@macro flutter.widgets.widgetsApp.onUnknownRoute}
  final RouteFactory? onUnknownRoute;

  /// {@macro flutter.widgets.widgetsApp.navigatorObservers}
  final List<NavigatorObserver>? navigatorObservers;

  /// {@macro flutter.widgets.widgetsApp.routeInformationProvider}
  final RouteInformationProvider? routeInformationProvider;

  /// {@macro flutter.widgets.widgetsApp.routeInformationParser}
  final RouteInformationParser<Object>? routeInformationParser;

  /// {@macro flutter.widgets.widgetsApp.routerDelegate}
  final RouterDelegate<Object>? routerDelegate;

  /// {@macro flutter.widgets.widgetsApp.backButtonDispatcher}
  final BackButtonDispatcher? backButtonDispatcher;

  /// {@macro flutter.widgets.widgetsApp.builder}
  final TransitionBuilder? builder;

  /// {@macro flutter.widgets.widgetsApp.color}
  final Color? color;

  /// The default text style for [Text] in the application.
  final TextStyle? textStyle;

  /// {@macro flutter.widgets.widgetsApp.locale}
  final Locale? locale;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  ///
  /// Internationalized apps that require translations for one of the locales
  /// listed in [GlobalMaterialLocalizations] should specify this parameter
  /// and list the [supportedLocales] that the application can handle.
  ///
  /// ```dart
  /// import 'package:flutter_localizations/flutter_localizations.dart';
  /// HybridApp(
  ///   localizationsDelegates: [
  ///     // ... app-specific localization delegate[s] here
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///   ],
  ///   supportedLocales: [
  ///     const Locale('en', 'US'), // English
  ///     const Locale('he', 'IL'), // Hebrew
  ///     // ... other locales the app supports
  ///   ],
  ///   // ...
  /// )
  /// ```
  ///
  /// ## Adding localizations for a new locale
  ///
  /// The information that follows applies to the unusual case of an app
  /// adding translations for a language not already supported by
  /// [GlobalMaterialLocalizations].
  ///
  /// Delegates that produce [WidgetsLocalizations] and [MaterialLocalizations]
  /// are included automatically. Apps can provide their own versions of these
  /// localizations by creating implementations of
  /// [LocalizationsDelegate<WidgetsLocalizations>] or
  /// [LocalizationsDelegate<MaterialLocalizations>] whose load methods return
  /// custom versions of [WidgetsLocalizations] or [MaterialLocalizations].
  ///
  /// For example: to add support to [MaterialLocalizations] for a
  /// locale it doesn't already support, say `const Locale('foo', 'BR')`,
  /// one could just extend [DefaultMaterialLocalizations]:
  ///
  /// ```dart
  /// class FooLocalizations extends DefaultMaterialLocalizations {
  ///   FooLocalizations(Locale locale) : super(locale);
  ///   @override
  ///   String get okButtonLabel {
  ///     if (locale == const Locale('foo', 'BR'))
  ///       return 'foo';
  ///     return super.okButtonLabel;
  ///   }
  /// }
  ///
  /// ```
  ///
  /// A `FooLocalizationsDelegate` is essentially just a method that constructs
  /// a `FooLocalizations` object. We return a [SynchronousFuture] here because
  /// no asynchronous work takes place upon "loading" the localizations object.
  ///
  /// ```dart
  /// class FooLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  ///   const FooLocalizationsDelegate();
  ///   @override
  ///   Future<FooLocalizations> load(Locale locale) {
  ///     return SynchronousFuture(FooLocalizations(locale));
  ///   }
  ///   @override
  ///   bool shouldReload(FooLocalizationsDelegate old) => false;
  /// }
  /// ```
  ///
  /// Constructing a [HybridApp] with a `FooLocalizationsDelegate` overrides
  /// the automatically included delegate for [MaterialLocalizations] because
  /// only the first delegate of each [LocalizationsDelegate.type] is used and
  /// the automatically included delegates are added to the end of the app's
  /// [localizationsDelegates] list.
  ///
  /// ```dart
  /// HybridApp(
  ///   localizationsDelegates: [
  ///     const FooLocalizationsDelegate(),
  ///   ],
  ///   // ...
  /// )
  /// ```
  /// See also:
  ///
  ///  * [supportedLocales], which must be specified along with
  ///    [localizationsDelegates].
  ///  * [GlobalMaterialLocalizations], a [localizationsDelegates] value
  ///    which provides material localizations for many languages.
  ///  * The Flutter Internationalization Tutorial,
  ///    <https://flutter.dev/tutorials/internationalization/>.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// {@macro flutter.widgets.widgetsApp.localeListResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// {@macro flutter.widgets.LocaleResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleResolutionCallback? localeResolutionCallback;

  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  ///
  /// It is passed along unmodified to the [WidgetsApp] built by this widget.
  ///
  /// See also:
  ///
  ///  * [localizationsDelegates], which must be specified for localized
  ///    applications.
  ///  * [GlobalMaterialLocalizations], a [localizationsDelegates] value
  ///    which provides material localizations for many languages.
  ///  * The Flutter Internationalization Tutorial,
  ///    <https://flutter.dev/tutorials/internationalization/>.
  final Iterable<Locale> supportedLocales;

  /// Turns on a performance overlay.
  ///
  /// See also:
  ///
  ///  * <https://flutter.dev/debugging/#performanceoverlay>
  final bool showPerformanceOverlay;

  /// Turns on checkerboarding of raster cache images.
  final bool checkerboardRasterCacheImages;

  /// Turns on checkerboarding of layers rendered to offscreen bitmaps.
  final bool checkerboardOffscreenLayers;

  /// Turns on an overlay that shows the accessibility information
  /// reported by the framework.
  final bool showSemanticsDebugger;

  /// {@macro flutter.widgets.widgetsApp.debugShowCheckedModeBanner}
  final bool debugShowCheckedModeBanner;

  /// {@macro flutter.widgets.widgetsApp.shortcuts}
  /// {@tool snippet}
  /// This example shows how to add a single shortcut for
  /// [LogicalKeyboardKey.select] to the default shortcuts without needing to
  /// add your own [Shortcuts] widget.
  ///
  /// Alternatively, you could insert a [Shortcuts] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     shortcuts: <LogicalKeySet, Intent>{
  ///       ... WidgetsApp.defaultShortcuts,
  ///       LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget? child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.shortcuts.seeAlso}
  final Map<LogicalKeySet, Intent>? shortcuts;

  /// {@macro flutter.widgets.widgetsApp.actions}
  /// {@tool snippet}
  /// This example shows how to add a single action handling an
  /// [ActivateAction] to the default actions without needing to
  /// add your own [Actions] widget.
  ///
  /// Alternatively, you could insert a [Actions] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     actions: <Type, Action<Intent>>{
  ///       ... WidgetsApp.defaultActions,
  ///       ActivateAction: CallbackAction(
  ///         onInvoke: (Intent intent) {
  ///           // Do something here...
  ///           return null;
  ///         },
  ///       ),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget? child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.actions.seeAlso}
  final Map<Type, Action<Intent>>? actions;

  /// {@macro flutter.widgets.widgetsApp.restorationScopeId}
  final String? restorationScopeId;

  /// Turns on a [GridPaper] overlay that paints a baseline grid
  /// Material apps.
  ///
  /// Only available in checked mode.
  ///
  /// See also:
  ///
  ///  * <https://material.io/design/layout/spacing-methods.html>
  final bool debugShowMaterialGrid;
  
  @override
  State<StatefulWidget> createState() {
    return _HybridAppState();
  }

  /// The [HeroController] used for Material page transitions.
  ///
  /// Used by the [HybridApp].
  static HeroController createMaterialHeroController() {
    return HeroController(
      createRectTween: (Rect? begin, Rect? end) {
        return MaterialRectArcTween(begin: begin, end: end);
      },
    );
  }
}


class _StaticScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    // Never build any overscroll glow indicators.
    return child;
  }
}

class _HybridAppState extends State<HybridApp> with WidgetsBindingObserver {
  late HeroController _heroController;
  final Map<int, HybridRoute> _routes = {};
  List<Map> _pendingNewRoutes = [];
  final Map<int, GlobalKey<NavigatorState>?> _subNavigators = {};
  GlobalKey<NavigatorState>? _navigator;

  @override
  void initState() {
    super.initState();
    _navigator = widget.navigatorKey ?? GlobalObjectKey<NavigatorState>(this);
    _heroController = HybridApp.createMaterialHeroController();
    HybridChannels.navigation.setMethodCallHandler(_handleNavigationInvocation);
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didUpdateWidget(HybridApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigatorKey != oldWidget.navigatorKey) {
      _navigator = widget.navigatorKey ?? GlobalObjectKey<NavigatorState>(this);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  bool get _usesRouter => widget.routerDelegate != null;

  Widget _inspectorSelectButtonBuilder(BuildContext context, VoidCallback onPressed) {
    return TextButton(
      child: const Icon(Icons.search),
      onPressed: onPressed,
    );
  }

  // Combine the Localizations for Material with the ones contributed
  // by the localizationsDelegates parameter, if any. Only the first delegate
  // of a particular LocalizationsDelegate.type is loaded so the
  // localizationsDelegate parameter can be used to override
  // _MaterialLocalizationsDelegate.
  Iterable<LocalizationsDelegate<dynamic>> get _localizationsDelegates sync* {
    if (widget.localizationsDelegates != null) {
      yield* widget.localizationsDelegates!;
    }
    yield DefaultMaterialLocalizations.delegate;
    yield DefaultCupertinoLocalizations.delegate;
  }

  Widget _buildWidgetApp(BuildContext context) {
    Color color = widget.color ?? Colors.white;
    if (_usesRouter) {
      return WidgetsApp.router(
        key: GlobalObjectKey(this),
        routeInformationProvider: widget.routeInformationProvider,
        routeInformationParser: widget.routeInformationParser!,
        routerDelegate: widget.routerDelegate!,
        backButtonDispatcher: widget.backButtonDispatcher,
        builder: widget.builder,
        textStyle: widget.textStyle,
        color: color,
        locale: widget.locale,
        localizationsDelegates: _localizationsDelegates,
        localeResolutionCallback: widget.localeResolutionCallback,
        localeListResolutionCallback: widget.localeListResolutionCallback,
        supportedLocales: widget.supportedLocales,
        showPerformanceOverlay: widget.showPerformanceOverlay,
        checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
        checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
        showSemanticsDebugger: widget.showSemanticsDebugger,
        debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
        inspectorSelectButtonBuilder: _inspectorSelectButtonBuilder,
        shortcuts: widget.shortcuts,
        actions: widget.actions,
        restorationScopeId: widget.restorationScopeId,
      );
    }
    return WidgetsApp(
      key: GlobalObjectKey(this),
      navigatorKey: _navigator,
      navigatorObservers: [HybridNavigatorObserverProxy(observers: widget.navigatorObservers!)],
      initialRoute: widget.initialRoute,
      onGenerateRoute: widget.onGenerateRoute,
      onGenerateInitialRoutes: (String initialRouteName) {
        List<Route<dynamic>> routes = [_buildHybridRoute(initialRouteName)];
        if (_pendingNewRoutes.isNotEmpty) {
          for (var i = 0; i < _pendingNewRoutes.length; i++) {
            final routeParams = _pendingNewRoutes[i];
            routes.add(_buildHybridRoute(
              routeParams['route'] as String,
              routeId: routeParams['routeId'] as int
            ));
          }
          _pendingNewRoutes = [];
        }
        return routes;
      },
      onUnknownRoute: widget.onUnknownRoute,
      builder: widget.builder,
      textStyle: widget.textStyle,
      color: color,
      locale: widget.locale,
      localizationsDelegates: _localizationsDelegates,
      localeResolutionCallback: widget.localeResolutionCallback,
      localeListResolutionCallback: widget.localeListResolutionCallback,
      supportedLocales: widget.supportedLocales,
      showPerformanceOverlay: widget.showPerformanceOverlay,
      checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
      showSemanticsDebugger: widget.showSemanticsDebugger,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      inspectorSelectButtonBuilder: _inspectorSelectButtonBuilder,
      shortcuts: widget.shortcuts,
      actions: widget.actions,
      restorationScopeId: widget.restorationScopeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _StaticScrollBehavior(),
      child: HeroControllerScope(
        controller: _heroController,
        child: Builder(
          builder: _buildWidgetApp,
        ),
      )
    );
  }

  Route<dynamic> _buildHybridRoute(String initialRoute, {int routeId = 0}) {
    final subNavigator = GlobalObjectKey<NavigatorState>(initialRoute);
    final route = HybridRoute(
      settings: RouteSettings(name: initialRoute),
      routeId: routeId,
      builder: (BuildContext ctx) {
        return Navigator(
          key: subNavigator,
          initialRoute: initialRoute,
          onGenerateInitialRoutes: (navigator, initialRouteName) {
            if (widget.onGenerateInitialRoutes != null) {
              return widget.onGenerateInitialRoutes!.call(initialRouteName);
            }
            return Navigator.defaultGenerateInitialRoutes(navigator, initialRouteName);
          },
          onGenerateRoute: widget.onGenerateRoute,
          observers: [HybridNavigatorObserverProxy(observers: widget.navigatorObservers ?? [])],
        );
      },
    );
    _routes[routeId] = route;
    _subNavigators[routeId] = subNavigator;
    return route;
  }

  Future<dynamic> _handleNavigationInvocation(MethodCall call) {
    switch (call.method) {
      case 'removeRoute':
        return handleRemoveRoute(call.arguments as int);
      case 'newRoute':
        return handleNewRoute(call.arguments as Map);
    }
    return Future<dynamic>.value();
  }
  
  Future<bool> handleRemoveRoute(int routeId) async {
    final NavigatorState? navigator = _navigator?.currentState;
    if (navigator == null) {
      return false;
    }
    if (_routes.isNotEmpty && _routes.containsKey(routeId)) {
      final route = _routes.remove(routeId);
      _subNavigators.remove(routeId);
      if (route != null) {
        navigator.removeRoute(route);
        route.didComplete(null);
      }
    }
    return true;
  }

  Future<bool> handleNewRoute(Map routeParams) async {
    final NavigatorState? navigator = _navigator?.currentState;
    if (navigator == null) {
      _pendingNewRoutes.add(routeParams);
      return false;
    }
    navigator.push(_buildHybridRoute(
      routeParams['route'] as String,
      routeId: routeParams['routeId'] as int
    ));
    return true;
  }

  // On Android: the user has pressed the back button.
  @override
  Future<bool> didPopRoute() async {
    assert(mounted);
    // The back button dispatcher should handle the pop route if we use a
    // router.
    if (_usesRouter) {
      return false;
    }

    final NavigatorState? navigator = _subNavigators.values.last?.currentState;
    if (navigator == null) {
      return false;
    }
    return await navigator.maybePop();
  }

  @override
  Future<bool> didPushRoute(String route) async {
    assert(mounted);
    // The route name provider should handle the push route if we uses a
    // router.
    if (_usesRouter) {
      return false;
    }

    final NavigatorState? navigator = _navigator?.currentState;
    if (navigator == null) {
      return false;
    }
    navigator.pushNamed(route);
    return true;
  }
}