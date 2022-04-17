import 'package:flutter/widgets.dart';

import 'channels.dart';
import 'route.dart';

class HybridNavigator {

  const HybridNavigator._();

  /// Close the Flutter hybrid container (A FlutterFragment/FlutterActivity, or a FlutterViewController).
  ///
  /// On Android, removes this activity from the stack and returns to
  /// the previous activity.
  ///
  /// On iOS, calls `popViewControllerAnimated:` if the root view
  /// controller is a `UINavigationController`, or
  /// `dismissViewControllerAnimated:completion:` if the top view
  /// controller is a `FlutterViewController`.
  ///
  /// The optional `animated` parameter is ignored on all platforms
  /// except iOS where it is an argument to the aforementioned
  /// methods.
  ///
  /// This method should be preferred over calling `dart:io`'s [exit]
  /// method, as the latter may cause the underlying platform to act
  /// as if the application had crashed.
  static void pop<T>(BuildContext context, [T? result]) async {
    try {
      final route = HybridRoute.of(context);
      await HybridChannels.navigation.invokeMethod<void>('pop', {
        'routeId': route?.routeId,
        'result': result,
      });
    } catch (e) {
      FlutterError.onError?.call(FlutterErrorDetails(exception: e));
    }
  }

  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName,
    {
      Map<String, String?>? arguments,
    }
  ) async {
    try {
      final route = HybridRoute.of<T>(context);
      await HybridChannels.navigation.invokeMethod<void>('push', {
        'route': routeName,
        'routeId': route?.routeId,
        'arguments': arguments,
      });
      return route?.nextRoutePopped;
    } catch (e) {
      FlutterError.onError?.call(FlutterErrorDetails(exception: e));
    }
  }

}


class HybridNavigatorObserverProxy extends NavigatorObserver {

  final List<NavigatorObserver> observers;

  HybridNavigatorObserverProxy({this.observers = const <NavigatorObserver>[]});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in observers) {
      observer.didPush(route, previousRoute);
    }
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in observers) {
      observer.didPop(route, previousRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in observers) {
      observer.didRemove(route, previousRoute);
    }
  }

  @override
  void didReplace({ Route<dynamic>? newRoute, Route<dynamic>? oldRoute }) {
    for (final observer in observers) {
      observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    }
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in observers) {
      observer.didStartUserGesture(route, previousRoute);
    }
  }

  @override
  void didStopUserGesture() {
    for (final observer in observers) {
      observer.didStopUserGesture();
    }
  }
  
}