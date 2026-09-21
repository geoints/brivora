package com.example.brivora

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "brivora/pdf_share"
    private val fileProviderAuthority = "com.example.brivora.fileprovider"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "sharePdfToApp") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val target = call.argument<String>("target")
                val fileName = call.argument<String>("fileName")
                val bytes = call.argument<ByteArray>("bytes")

                if (target == null || fileName == null || bytes == null) {
                    result.error("INVALID_ARGUMENT", "Не хватает данных для отправки PDF.", null)
                    return@setMethodCallHandler
                }

                try {
                    val targetPackages = when (target) {
                        "whatsapp" -> listOf("com.whatsapp", "com.whatsapp.w4b")
                        "telegram" -> listOf("org.telegram.messenger")
                        else -> emptyList()
                    }

                    if (targetPackages.isEmpty()) {
                        result.error("INVALID_TARGET", "Неизвестный способ отправки.", null)
                        return@setMethodCallHandler
                    }

                    val safeName = fileName.replace(Regex("[^A-Za-z0-9._-]"), "_")
                    val pdfFile = File(cacheDir, safeName)
                    pdfFile.writeBytes(bytes)

                    val uri: Uri = FileProvider.getUriForFile(
                        this,
                        fileProviderAuthority,
                        pdfFile
                    )

                    var launched = false

                    for (packageName in targetPackages) {
                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = "application/pdf"
                            putExtra(Intent.EXTRA_STREAM, uri)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            setPackage(packageName)
                        }

                        try {
                            startActivity(intent)
                            launched = true
                            break
                        } catch (_: ActivityNotFoundException) {
                            // Try the next package, e.g. WhatsApp Business.
                        }
                    }

                    if (!launched) {
                        result.error("APP_NOT_INSTALLED", "Приложение не установлено.", null)
                        return@setMethodCallHandler
                    }

                    result.success(null)
                } catch (e: Exception) {
                    result.error("SHARE_FAILED", e.message, null)
                }
            }
    }
}
