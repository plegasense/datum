package app.datum.datum

import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/// Recibe archivos desde "Abrir con" / "Compartir" y los copia a la caché para que Dart los abra por ruta.
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pending: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dovexa/intent")
        channel!!.setMethodCallHandler { call, result ->
            if (call.method == "initial") {
                val p = pending
                pending = null
                result.success(p)
            } else result.notImplemented()
        }
        handle(intent, initial = true)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handle(intent, initial = false)
    }

    private fun handle(i: Intent?, initial: Boolean) {
        val uri: Uri? = when (i?.action) {
            Intent.ACTION_VIEW -> i.data
            Intent.ACTION_SEND -> @Suppress("DEPRECATION") i.getParcelableExtra(Intent.EXTRA_STREAM)
            else -> null
        }
        if (uri == null) return
        i?.action = null
        Thread {
            val path = copyToCache(uri)
            Handler(Looper.getMainLooper()).post {
                if (path == null) return@post
                if (initial) pending = path else channel?.invokeMethod("open", path)
            }
        }.start()
    }

    private fun copyToCache(uri: Uri): String? = try {
        var name = uri.lastPathSegment?.substringAfterLast('/') ?: "archivo"
        contentResolver.query(uri, null, null, null, null)?.use { c ->
            val k = c.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (k >= 0 && c.moveToFirst()) c.getString(k)?.let { name = it }
        }
        name = name.replace(Regex("[\\\\/:*?\"<>|]"), "_")
        val dir = File(cacheDir, "compartido")
        dir.deleteRecursively()
        dir.mkdirs()
        val out = File(dir, name)
        contentResolver.openInputStream(uri)?.use { inp -> out.outputStream().use { inp.copyTo(it) } }
        out.path
    } catch (e: Exception) {
        null
    }
}
