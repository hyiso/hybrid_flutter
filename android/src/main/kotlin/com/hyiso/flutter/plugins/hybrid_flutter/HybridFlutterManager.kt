package com.hyiso.flutter.plugins.hybrid_flutter

import android.content.Context
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngine.EngineLifecycleListener
import io.flutter.embedding.engine.FlutterEngineGroup
import java.lang.ref.WeakReference


object HybridFlutterManager {
  private var engineGroup: FlutterEngineGroup? = null
  private var rootEngine: FlutterEngine? = null
  private var spawnCount = 0
  private var shareCount = 0
  private var uniqueRouteId = 0
  private val fragmentMap: MutableMap<Number, WeakReference<FlutterFragment?>>

  var navigator: IHybridFlutterNavigator? = null

  // Whether root engine is created for preload strategy.
  private var isPreloadRootEngine = false

  init {
    fragmentMap = HashMap()
  }

  fun preloadRootEgnine(context: Context) {
    if (!isPreloadRootEngine) {
      isPreloadRootEngine = true
      createRootEngine(context)
    }
  }

  fun unloadRootEngine() {
    if (isPreloadRootEngine) {
      isPreloadRootEngine = false
      destroyRootEngine()
    }
  }

  private fun createRootEngine(context: Context) {
    if (engineGroup == null) {
      engineGroup = FlutterEngineGroup(context)
    }
    if (rootEngine == null) {
      rootEngine = engineGroup!!.createAndRunDefaultEngine(context)
    }
  }

  private fun destroyRootEngine() {
    if (isPreloadRootEngine) {
      return
    }
    // root engine is still in use
    if (spawnCount > 0 || shareCount > 0) {
      return
    }
    if (rootEngine != null) {
      rootEngine!!.destroy()
      rootEngine = null
    }
    engineGroup = null
  }

  fun shareFlutterEngine(context: Context): FlutterEngine? {
    createRootEngine(context)
    ++shareCount
    return rootEngine
  }

  fun releaseSharedEngine() {
    --shareCount
    if (shareCount < 0) {
      shareCount = 0
    }
    destroyRootEngine()
  }

  fun spawnFlutterEngine(context: Context): FlutterEngine {
    // In Flutter SDK 2.10.3
    // When spawn engine and then destroy first engine immediately
    // spawned engine will lost image decoder registry
    // See issue：https://github.com/flutter/flutter/issues/98013
    //
    // to avoid this bug,
    // we keep the root engine, only use spawned engine.
    createRootEngine(context)
    ++spawnCount
    val engine = engineGroup!!.createAndRunDefaultEngine(context)
    engine.addEngineLifecycleListener(object : EngineLifecycleListener {
      override fun onPreEngineRestart() {}
      override fun onEngineWillDestroy() {
        --spawnCount
        if (spawnCount < 0) {
          spawnCount = 0
        }
        destroyRootEngine()
      }
    })
    return engine
  }

  fun newRoute(route: String?, flutterFragment: FlutterFragment): Int {
    val routeId = ++uniqueRouteId
    if (route != null && route != "/") {
      HybridFlutterPlugin.fromEngine(flutterFragment.flutterEngine)?.newRoute(route, routeId)
    }
    fragmentMap[routeId] = WeakReference(flutterFragment)
    return routeId
  }

  fun removeRoute(routeId: Int) {
    val fragmentRef = fragmentMap.remove(routeId)
    HybridFlutterPlugin.fromEngine(fragmentRef?.get()?.flutterEngine)?.removeRoute(routeId)
  }

  fun getFlutterFragment(routeId: Int): FlutterFragment? {
    val reference = fragmentMap[routeId]
    return reference?.get()
  }

  // FlutterEngine's LifecycleChannel is intercepted in Engine shell.
  // AppLifecycleState.paused and AppLifecycleState.detach will stop animator
  // AppLifecycleState.inactive and AppLifecycleState.resume will start animator
  // See https://github.com/flutter/engine/blob/75bef9f6c8ac2ed4e1e04cdfcd88b177d9f1850d/shell/common/engine.cc#L346
  //
  // Here to keep animator as engine is still in use.
  fun fixSharedEngineLifecycle() {
    rootEngine?.lifecycleChannel?.appIsInactive()
  }
}
