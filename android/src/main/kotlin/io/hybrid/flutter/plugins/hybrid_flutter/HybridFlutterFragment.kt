package io.hybrid.flutter.plugins.hybrid_flutter

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.view.View
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.platform.PlatformPlugin


open class HybridFlutterFragment : FlutterFragment() {

  private var routeId:Int = -1
  private lateinit var delegate: HybridFlutterFragmentDelegate

  open fun shouldUseNewEngine(): Boolean {
    return false
  }

  open fun shouldSnapshotForLeaving(): Boolean {
    return false
  }

  override fun onAttach(context: Context) {
    super.onAttach(context)
    delegate = HybridFlutterFragmentDelegate(this)
    if (!shouldUseNewEngine()) {
      delegate.onAttach(context)
    }
  }

  override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)
    delegate.onViewCreated(view, savedInstanceState)
    routeId = HybridFlutterManager.newRoute(initialRoute, this)
  }

  private fun attachToFlutterEngine() {
    if (!shouldUseNewEngine()) {
      delegate.attachToFlutterEngine()
      onAttachToFlutterEngine()
    }
  }

  open fun onAttachToFlutterEngine() {
    // do nothing
  }

  override fun onStart() {
    super.onStart()
    attachToFlutterEngine()
  }

  override fun onResume() {
    super.onResume()
    updateHybridAppLifecycleState(HybridFlutterPlugin.LIFECYCLE_RESUMED)
  }

  override fun onPostResume() {
    super.onPostResume()
    delegate.updateSystemUiOverlays()
  }

  override fun onPause() {
    super.onPause()
    updateHybridAppLifecycleState(HybridFlutterPlugin.LIFECYCLE_INACTIVE)
    // If sharing FlutterEngine with multi FlutterFragment(s)
    // When leaving this Activity and FlutterFragment
    // and under stack Activity also contains FlutterFragment
    // the under FlutterFragment will show this Fragment's Flutter Route content.

    // So we convert FlutterView to FlutterImageView
    // And remove this Fragment's Flutter Route
    val activity: Activity? = activity
    if (activity != null && activity.isFinishing) {
      if (shouldSnapshotForLeaving()) {
        delegate.flutterView?.convertToImageView()
        HybridFlutterManager.removeRoute(routeId)
      }
    }
  }

  override fun onStop() {
    super.onStop()
    updateHybridAppLifecycleState(HybridFlutterPlugin.LIFECYCLE_PAUSED)
    // super.onStop will send AppLifecycleState.paused to engine shell
    // which intercepted this message and then stop animator
    // See https://github.com/flutter/engine/blob/75bef9f6c8ac2ed4e1e04cdfcd88b177d9f1850d/shell/common/engine.cc#L346
    //
    // When FlutterEngine is still used by other FlutterFragment,
    // We need to fix AppLifecycleState by LifecycleChannel
    if (!stillAttachedForEvent("onStop")) {
      HybridFlutterManager.fixSharedEngineLifecycle()
    }
  }

  override fun onDetach() {
    if (!shouldUseNewEngine()) {
      delegate.onDetach()
    }
    // super.onDetach will release FlutterEngine
    // If we need to do something with FlutterEngine,
    // calling it before super.onDetach
    HybridFlutterManager.removeRoute(routeId)
    updateHybridAppLifecycleState(HybridFlutterPlugin.LIFECYCLE_DETACHED)
    super.onDetach()
    // super.onStop will send AppLifecycleState.detached to engine shell
    // which intercepted this message and then stop animator
    // See https://github.com/flutter/engine/blob/75bef9f6c8ac2ed4e1e04cdfcd88b177d9f1850d/shell/common/engine.cc#L346
    //
    // When FlutterEngine is still used by other FlutterFragment,
    // We need to fix AppLifecycleState by LifecycleChannel
    if (!stillAttachedForEvent("onDetach")) {
      HybridFlutterManager.fixSharedEngineLifecycle()
    }
    if (!shouldUseNewEngine()) {
      HybridFlutterManager.releaseSharedEngine()
    }
  }

  override fun setUserVisibleHint(isVisibleToUser: Boolean) {
    super.setUserVisibleHint(isVisibleToUser)
    if (isVisibleToUser) {
      attachToFlutterEngine()
    }
  }

  override fun onHiddenChanged(hidden: Boolean) {
    super.onHiddenChanged(hidden)
    if (!hidden) {
      attachToFlutterEngine()
    }
  }

  private fun stillAttachedForEvent(event: String): Boolean {
    return shouldUseNewEngine() || delegate.isAttachedToFlutterEngine
  }

  private fun updateHybridAppLifecycleState(state: String) {
    if (stillAttachedForEvent(state)) {
      HybridFlutterPlugin.fromEngine(flutterEngine)?.sendLifecycleMessage(state)
    }
  }

  override fun shouldAttachEngineToActivity(): Boolean {
    return shouldUseNewEngine()
  }

  override fun shouldDestroyEngineWithHost(): Boolean {
    return shouldUseNewEngine()
  }

  override fun updateSystemUiOverlays() {
    super.updateSystemUiOverlays()
    delegate.updateSystemUiOverlays()
  }

  /**
   * As FlutterActivityAndFragmentDelegate#onDetach will destroy PlatformPlugin,
   * which will set PlatformChannel.platformMessageHandler to null,
   * thus PlatformChannel will not work.
   */
  override fun providePlatformPlugin(
    activity: Activity?,
    flutterEngine: FlutterEngine
  ): PlatformPlugin? {
    if (!shouldUseNewEngine()) {
      return null
    }
    return super.providePlatformPlugin(activity, flutterEngine)
  }

  override fun provideFlutterEngine(context: Context): FlutterEngine? {
    return if (shouldUseNewEngine()) {
      HybridFlutterManager.spawnFlutterEngine(context)
    } else HybridFlutterManager.shareFlutterEngine(context)
  }
}
