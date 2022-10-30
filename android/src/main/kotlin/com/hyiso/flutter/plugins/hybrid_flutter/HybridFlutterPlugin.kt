package com.hyiso.flutter.plugins.hybrid_flutter

import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.StringCodec


/** HybridFlutterPlugin  */
class HybridFlutterPlugin : FlutterPlugin {

  private var lifecycleChannel: BasicMessageChannel<String>? = null
  private var navigationChannel: MethodChannel? = null

  companion object {
    const val LIFECYCLE_RESUMED = "HybridAppLifecycleState.resumed"
    const val LIFECYCLE_INACTIVE = "HybridAppLifecycleState.inactive"
    const val LIFECYCLE_PAUSED = "HybridAppLifecycleState.paused"
    const val LIFECYCLE_DETACHED = "HybridAppLifecycleState.detached"
    private const val TAG = "HybridFlutterPlugin"

    fun fromEngine(engine: FlutterEngine?): HybridFlutterPlugin? {
      if (engine != null && engine.plugins.has(HybridFlutterPlugin::class.java)) {
        val plugin = engine.plugins[HybridFlutterPlugin::class.java]
        if (plugin is HybridFlutterPlugin) {
          return plugin
        }
      }
      return null
    }
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    lifecycleChannel = BasicMessageChannel(binding.binaryMessenger, "hybrid/lifecycle", StringCodec.INSTANCE)
    navigationChannel = MethodChannel(binding.binaryMessenger, "hybrid/navigation")
    navigationChannel!!.setMethodCallHandler(MethodCallHandler { call, result ->
      val navigator = HybridFlutterManager.navigator
      if (navigator == null) {
        result.error("no_navigator", "navigator not provided", null)
        return@MethodCallHandler
      }
      if ("pop" == call.method) {
        val routeId = call.argument<Int>("routeId")
        val data = call.argument<Any>("result")
        val flutterFragment = HybridFlutterManager.getFlutterFragment(routeId!!)
        if (flutterFragment != null && flutterFragment.activity != null) {
          navigator?.pop(flutterFragment.activity, data)
        }
      } else if ("push" == call.method) {
        val routeId = call.argument<Int>("routeId")
        val route = call.argument<String>("route")
        val arguments = call.argument<HashMap<String, String>>("arguments")
        val flutterFragment = HybridFlutterManager.getFlutterFragment(routeId!!)
        if (flutterFragment != null) {
          navigator?.push(route!!, arguments, flutterFragment.context)
        }
      }
    })
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    lifecycleChannel = null
    navigationChannel!!.setMethodCallHandler(null)
    navigationChannel = null
  }

  fun newRoute(route: String, routeId: Int) {
    Log.v(TAG, "Sending message to push route '$route' with routeId $routeId")
    val arguments: MutableMap<String, Any> = HashMap()
    arguments["route"] = route
    arguments["routeId"] = routeId
    navigationChannel!!.invokeMethod("newRoute", arguments)
  }

  fun removeRoute(routeId: Int) {
    Log.v(TAG, "Sending message to pop route.")
    navigationChannel!!.invokeMethod("removeRoute", routeId)
  }

  fun sendLifecycleMessage(message: String) {
    Log.v(TAG, "Sending lifecycle message: $message")
    lifecycleChannel?.send(message)
  }
}
