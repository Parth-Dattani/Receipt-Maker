package com.pixelperfect.receipt

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant // આ ખૂટતું હતું

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // પ્લગિન રજીસ્ટ્રેશન
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        // તમારું કસ્ટમ પ્લગિન રજીસ્ટર કરો
        flutterEngine.plugins.add(InvoiceSathiAndroidPlugin())
    }
}