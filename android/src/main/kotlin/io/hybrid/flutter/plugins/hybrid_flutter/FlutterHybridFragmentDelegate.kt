package io.hybrid.flutter.plugins.hybrid_flutter

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import io.flutter.embedding.android.ExclusiveAppComponent
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine

internal class FlutterHybridFragmentDelegate(fragment: FlutterFragment) : ExclusiveAppComponent<Activity?> {

  private var fragment: FlutterFragment?
  var flutterView: FlutterView? = null
    private set
  private var flutterEngine: FlutterEngine?
  var isAttachedToFlutterEngine = false
    private set

  init {
    this.fragment = fragment
    flutterEngine = fragment.flutterEngine
  }

  private fun findFlutterView(view: View) {
    if (view is FlutterView) {
      flutterView = view
      return
    }
    if (view is ViewGroup) {
      for (i in 0 until view.childCount) {
        val child = view.getChildAt(i)
        if (child is FlutterView) {
          flutterView = child
          return
        } else {
          findFlutterView(child)
        }
      }
    }
  }

  fun attachToFlutterEngine() {
    if (isAttachedToFlutterEngine) {
      return
    }
    isAttachedToFlutterEngine = true
    // This will detach previous delegate from engine
    flutterEngine!!.activityControlSurface.attachToActivity(this, fragment!!.lifecycle)
    // Here attach this FlutterView to FlutterEngine
    // as reason in #detachFromFlutterEngine
    if (flutterView != null) {
      flutterView!!.attachToFlutterEngine(flutterEngine!!)
    }
  }

  fun onAttach(context: Context) {
    attachToFlutterEngine()
  }

  fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    findFlutterView(view)
  }

  fun onDetach() {
    if (isAttachedToFlutterEngine) {
      flutterEngine!!.activityControlSurface.detachFromActivity()
    }
    fragment = null
    flutterEngine = null
    flutterView = null
  }

  override fun detachFromFlutterEngine() {
    isAttachedToFlutterEngine = false
    // Before next FlutterView attach to FlutterEngine,
    // We should detach this FlutterView from FlutterEngine
    // to avoid some plugins（like TextInputPlugin） losing channels.
    flutterView?.detachFromFlutterEngine()
  }

  override fun getAppComponent(): Activity {
    return fragment!!.requireActivity()
  }
}
