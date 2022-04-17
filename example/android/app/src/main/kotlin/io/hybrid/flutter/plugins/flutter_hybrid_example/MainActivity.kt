package io.hybrid.flutter.plugins.hybrid_flutter_example

import android.app.Activity
import android.content.Intent
import android.os.Bundle

class MainActivity: Activity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val intent = Intent(this, MainFragmentActivity::class.java)
    startActivity(intent)
    finish()
  }
}
