import 'package:flutter/cupertino.dart';
import 'package:hybrid_flutter/hybrid_flutter.dart';

class MyRoute<T> extends CupertinoPageRoute<T> with HybridRouteMixin<T> {
  MyRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
    builder: builder,
    settings: settings,
    maintainState: maintainState,
    fullscreenDialog: fullscreenDialog,
  );

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);
}