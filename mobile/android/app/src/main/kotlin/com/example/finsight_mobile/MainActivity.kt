package com.example.finsight_mobile

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "finsight.native/downloads"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveFile") {
                val fileName = call.argument<String>("fileName")
                val mimeType = call.argument<String>("mimeType")
                val bytes = call.argument<ByteArray>("bytes")

                if (fileName == null || mimeType == null || bytes == null) {
                    result.error("INVALID_ARGS", "Missing arguments", null)
                    return@setMethodCallHandler
                }

                try {
                    val path = saveToDownloads(fileName, mimeType, bytes)
                    if (path != null) {
                        result.success(path)
                    } else {
                        result.error("SAVE_FAILED", "Could not save to native downloads folder", null)
                    }
                } catch (e: Exception) {
                    result.error("SAVE_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveToDownloads(fileName: String, mimeType: String, bytes: ByteArray): String? {
        val resolver = contentResolver
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val contentValues = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            }
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
            if (uri != null) {
                resolver.openOutputStream(uri)?.use { 
                    it.write(bytes) 
                }
                "Downloads Folder ($fileName)" 
            } else {
                null
            }
        } else {
            val dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!dir.exists()) dir.mkdirs()
            val file = File(dir, fileName)
            FileOutputStream(file).use {
                it.write(bytes)
            }
            file.absolutePath
        }
    }
}
