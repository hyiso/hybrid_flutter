import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HybridRoute<T> extends PageRoute<T> with HybridRouteMixin<T> {
  HybridRoute({
    required this.builder,
    required this.routeId,
    RouteSettings? settings,
    this.maintainState = true,
  }) : super(settings: settings);
  
  final WidgetBuilder builder;

  final int routeId;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  final bool maintainState;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation) => builder(context);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
     return builder(context);
  }

  @override
  bool get isFirst => true;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => null;

  // The API for general users of this class

  /// Returns the hybrid route most closely associated with the given context.
  ///
  /// Returns null if the given context is not associated with a hybrid route.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// HybridRoute route = HybridRoute.of(context);
  /// ```
  ///
  /// The given [BuildContext] will be rebuilt if the state of the route changes
  /// while it is visible (specifically, if [isCurrent] or [canPop] change value).
  @optionalTypeArgs
  static HybridRoute<T>? of<T>(BuildContext context) {
    NavigatorState navigator = Navigator.of(context);
    if (navigator.mounted) {
      return ModalRoute.of(navigator.context) as HybridRoute<T>?;
    }
    return null;
  }


  /// A future that completes when next route is popped off the navigator.
  ///
  /// The future completes with the value given to [Navigator.pop], if any, or
  /// else the value of [currentResult]. See [didComplete] for more discussion
  /// on this topic.
  Future<T?> get nextRoutePopped => _nextPopCompleter.future;
  Completer<T?> _nextPopCompleter = Completer<T?>();

  HybridRoute? _previousHybridRoute;

  void _didCompleteNextRoute(T? result) {
    _nextPopCompleter.complete(result);
    _nextPopCompleter = Completer<T?>();
  }

  @override
  void didComplete(T? result) {
    super.didComplete(result);
    _previousHybridRoute?._didCompleteNextRoute(result);
  }

  @override
  void didChangePrevious(Route<dynamic>? previousRoute) {
    super.didChangePrevious(previousRoute);
    if (previousRoute is HybridRoute) {
      _previousHybridRoute = previousRoute;
    }
  }
}

mixin HybridRouteMixin<T> on Route<T> {

  @override
  bool get isCurrent {
    if (!super.isCurrent) {
      return false;
    }
    if (navigator?.mounted != true) {
      return false;
    }
    final parent = ModalRoute.of(navigator!.context);
    if (parent != null) {
      return parent.isCurrent;
    }
    return true;
  }
}