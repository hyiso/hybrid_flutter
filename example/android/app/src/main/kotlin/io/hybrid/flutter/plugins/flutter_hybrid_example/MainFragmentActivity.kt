package io.hybrid.flutter.plugins.hybrid_flutter_example

import android.content.Intent
import android.os.Bundle
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.android.FlutterFragment
import io.hybrid.flutter.plugins.hybrid_flutter.HybridFlutterManager

class MainFragmentActivity : FragmentActivity() {
  companion object {
    private const val TAG_FLUTTER_FRAGMENT: String = "flutter_fragment"
    const val KEY_ROUTE = "route"
    const val KEY_USE_NEW_ENGINE = "useNewEngine"
    var shareCount = 0
    var spawnCount = 0
  }

  private lateinit var flutterFragment: MainFlutterFragment

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    HybridFlutterManager.navigator = HybridFlutterNavigator
    setContentView(R.layout.activity_flutter)
    setupFragment()
  }

  private fun setupFragment() {
    var route = "/home"
    var params: MutableMap<String, String> = mutableMapOf()
    var useNewEngine = false
    val bundle = intent.extras
    if (bundle != null) {
      route = bundle.getString(KEY_ROUTE, "/home")
      useNewEngine = "1" == intent.getStringExtra(KEY_USE_NEW_ENGINE)
      bundle.remove(KEY_ROUTE)
      bundle.remove(KEY_USE_NEW_ENGINE)
      params = HashMap()
      bundle.keySet()?.let { set ->
        set.forEach { key ->
          val value = bundle[key]
          if (key != null && value != null) {
            params[key] = value.toString()
          }
        }
      }
    }
    if (useNewEngine) {
      params["index"] = "${++spawnCount}"
    } else {
      params["index"] = "${++shareCount}"
    }
    flutterFragment = FlutterFragment.NewEngineFragmentBuilder(MainFlutterFragment::class.java)
        .initialRoute(route, params)
        .build()
    flutterFragment.useNewEngine = useNewEngine

    supportFragmentManager
        .beginTransaction()
        .add(R.id.fragment_container, flutterFragment, TAG_FLUTTER_FRAGMENT)
        .commit()

  }

  override fun onPostResume() {
    super.onPostResume()
    flutterFragment.onPostResume()
  }

  override fun onNewIntent(intent: Intent?) {
    super.onNewIntent(intent)
    intent?.let {
      flutterFragment.onNewIntent(it)
    }
  }

  override fun onBackPressed() {
    flutterFragment.onBackPressed()
  }

  override fun onRequestPermissionsResult(
      requestCode: Int,
      permissions: Array<out String>,
      grantResults: IntArray,
  ) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    flutterFragment.onRequestPermissionsResult(
        requestCode,
        permissions,
        grantResults
    )
  }

  override fun onUserLeaveHint() {
    flutterFragment.onUserLeaveHint()
  }

  override fun onTrimMemory(level: Int) {
    super.onTrimMemory(level)
    flutterFragment.onTrimMemory(level)
  }

  @Override
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    flutterFragment.onActivityResult(requestCode, resultCode, data)
  }
}
