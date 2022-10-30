package com.hyiso.flutter.plugins.hybrid_flutter

import android.app.Activity
import android.content.Context

interface IHybridFlutterNavigator {
  fun push(route: String, arguments: HashMap<String, String>?, context: Context)
  fun pop(activity: Activity?, result: Any?)
}
