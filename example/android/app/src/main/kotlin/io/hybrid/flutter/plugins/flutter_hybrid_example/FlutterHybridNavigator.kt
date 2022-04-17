package io.hybrid.flutter.plugins.flutter_hybrid_example

import android.app.Activity
import android.content.Context
import android.content.Intent
import io.hybrid.flutter.plugins.flutter_hybrid.IFlutterHybridNavigator

object FlutterHybridNavigator : IFlutterHybridNavigator {
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