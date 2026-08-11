package com.pennyflow.app

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class ReportStorageHandler(private val activity: MainActivity) {
    companion object {
        const val CHANNEL = "com.pennyflow.app/report_storage"
        private const val RELATIVE_DIR = "PennyFlow/Reports"
    }

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler(::onMethodCall)
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "saveToDownloads" -> {
                val sourcePath = call.argument<String>("sourcePath")
                val displayName = call.argument<String>("displayName")
                val mimeType = call.argument<String>("mimeType")
                if (sourcePath == null || displayName == null || mimeType == null) {
                    result.error("INVALID_ARGS", "Missing saveToDownloads arguments", null)
                    return
                }
                try {
                    val path = saveFileToDownloads(sourcePath, displayName, mimeType)
                    result.success(path)
                } catch (e: Exception) {
                    result.error("SAVE_FAILED", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun saveFileToDownloads(
        sourcePath: String,
        displayName: String,
        mimeType: String,
    ): String {
        val sourceFile = File(sourcePath)
        val bytes = sourceFile.readBytes()
        val publicPath =
            File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                RELATIVE_DIR,
            )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val resolver = activity.contentResolver
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, displayName)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    Environment.DIRECTORY_DOWNLOADS + "/" + RELATIVE_DIR,
                )
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val uri =
                resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                    ?: throw IllegalStateException("Could not create download entry")
            resolver.openOutputStream(uri).use { output ->
                if (output == null) {
                    throw IllegalStateException("Could not open output stream")
                }
                output.write(bytes)
            }
            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            return File(publicPath, displayName).absolutePath
        }

        if (!publicPath.exists()) {
            publicPath.mkdirs()
        }
        val destination = File(publicPath, displayName)
        sourceFile.copyTo(destination, overwrite = true)
        return destination.absolutePath
    }
}
