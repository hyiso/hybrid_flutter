package com.hyiso.flutter.plugins.hybrid_flutter_example

import android.net.Uri
import io.flutter.embedding.android.FlutterFragment
import com.hyiso.flutter.plugins.hybrid_flutter.HybridFlutterFragment

class MainFlutterFragment : HybridFlutterFragment() {

  var useNewEngine:Boolean = false

  override fun shouldUseNewEngine(): Boolean {
    return useNewEngine
  }
}

fun FlutterFragment.NewEngineFragmentBuilder.initialRoute(
  route:String?,
  params: Map<String, String>?
): FlutterFragment.NewEngineFragmentBuilder {
  if (route == null || route.isEmpty()) {
    return this
  }
  val querySegments:ArrayList<String> = ArrayList()
  params?.keys?.let { set ->
    set.forEach { key ->
      val value = params[key]
      if (value != null) {
        querySegments.add("$key=${Uri.encode(value)}")
      }
    }
  }
  if (querySegments.isNotEmpty()) {
    return initialRoute("$route?${querySegments.joinToString("&")}")
  }
  return initialRoute(route)
}