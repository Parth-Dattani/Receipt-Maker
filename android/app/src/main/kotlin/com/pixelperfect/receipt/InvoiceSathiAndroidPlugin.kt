package com.pixelperfect.receipt

import android.app.Activity
import android.content.ClipData
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * App-local platform channels (not a pub.dev plugin). Registered from [MainActivity]
 * so hot-restart picks up Dart changes; native changes still require a full reinstall.
 */
class InvoiceSathiAndroidPlugin : FlutterPlugin, ActivityAware {
    private lateinit var appContext: Context
    private var activity: Activity? = null

    private var whatsappChannel: MethodChannel? = null
    private var fileProviderChannel: MethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext

        whatsappChannel = MethodChannel(binding.binaryMessenger, "invoice_sathi/whatsapp_share")
        whatsappChannel?.setMethodCallHandler(::onWhatsappMethod)

        fileProviderChannel = MethodChannel(binding.binaryMessenger, "invoice_sathi/file_provider")
        fileProviderChannel?.setMethodCallHandler(::onFileProviderMethod)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        whatsappChannel?.setMethodCallHandler(null)
        whatsappChannel = null
        fileProviderChannel?.setMethodCallHandler(null)
        fileProviderChannel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    private fun onWhatsappMethod(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "sendPdf") {
            result.notImplemented()
            return
        }

        val uriString = call.argument<String>("uri")
        val caption = (call.argument<String>("caption") ?: "").trim()
        val digits = (call.argument<String>("digits") ?: "").trim()
        if (uriString.isNullOrBlank() || digits.isBlank()) {
            result.error("bad_args", "uri/digits required", null)
            return
        }

        val stream = Uri.parse(uriString)
        val ctx: Context = activity ?: appContext

        fun trySend(packageName: String): Boolean {
            val intent =
                Intent(Intent.ACTION_SEND).apply {
                    setPackage(packageName)
                    type = "application/pdf"
                    putExtra(Intent.EXTRA_STREAM, stream)
                    if (caption.isNotEmpty()) {
                        putExtra(Intent.EXTRA_TEXT, caption)
                    }
                    putExtra("jid", "$digits@s.whatsapp.net")
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    clipData = ClipData.newRawUri("invoice_pdf", stream)
                }
            return try {
                ctx.startActivity(intent)
                true
            } catch (_: Exception) {
                false
            }
        }

        val ok = trySend("com.whatsapp") || trySend("com.whatsapp.w4b")
        result.success(ok)
    }

    private fun onFileProviderMethod(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getUriForFile") {
            result.notImplemented()
            return
        }

        val path = call.argument<String>("path")
        val authority = call.argument<String>("authority")
        if (path.isNullOrBlank() || authority.isNullOrBlank()) {
            result.error("bad_args", "path/authority required", null)
            return
        }

        val file = File(path)
        if (!file.exists()) {
            result.error("missing_file", "file does not exist: $path", null)
            return
        }

        val ctx: Context = activity ?: appContext

        try {
            val uri = FileProvider.getUriForFile(ctx, authority, file)
            result.success(uri.toString())
        } catch (e: Exception) {
            result.error("file_provider", e.message, null)
        }
    }
}
