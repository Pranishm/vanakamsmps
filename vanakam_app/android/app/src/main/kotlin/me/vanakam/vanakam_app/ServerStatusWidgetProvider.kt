package me.vanakam.vanakam_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.ComponentName
import android.app.PendingIntent
import android.widget.RemoteViews
import android.graphics.*
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import org.json.JSONObject
import java.net.URL
import java.net.HttpURLConnection
import kotlin.math.sin
import kotlin.math.cos
import es.antonborri.home_widget.HomeWidgetPlugin

class ServerStatusWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val ACTION_REFRESH = "me.vanakam.vanakam_app.REFRESH"
        private const val ACTION_UPDATE = "es.antonborri.home_widget.action.UPDATEWIDGET"
        private const val API = "https://api.mcsrvstat.us/3/marketing-great.gl.joinmc.link:25565"

        private val handler = Handler(Looper.getMainLooper())
        private var animRunnable: Runnable? = null
        private var frame = 0
        private var cachedStatus: S = S(false, 0, 0)
        private var lastFetchTime = 0L
        private var isLoading = false
        private var loadProgress = 0f
        
        private const val ANIM_INTERVAL = 1200L   // Refresh frame every 1.2s for smoothness
        private const val FETCH_INTERVAL = 45000L  // Refetch server data every 45s
    }

    override fun onEnabled(ctx: Context) {
        super.onEnabled(ctx)
        startAnimation(ctx)
    }

    override fun onUpdate(ctx: Context, mgr: AppWidgetManager, ids: IntArray) {
        for (id in ids) {
            updateUI(ctx, mgr, id)
        }
        startAnimation(ctx)
        fetchAsync(ctx)
    }

    override fun onReceive(ctx: Context, intent: Intent) {
        try {
            super.onReceive(ctx, intent)
            if (intent.action == ACTION_REFRESH || intent.action == ACTION_UPDATE) {
                readFlutterData(ctx)
                if (intent.action == ACTION_REFRESH) {
                    isLoading = true
                    loadProgress = 0f
                }
                fetchAsync(ctx)
                startAnimation(ctx)
            }
        } catch (_: Exception) {}
    }

    private fun readFlutterData(ctx: Context) {
        try {
            val data = HomeWidgetPlugin.getData(ctx)
            val state = data.getString("widget_state", "") ?: ""
            if (state.isNotEmpty()) {
                val on = state == "online"
                val cur = (data.getString("player_count", "0") ?: "0").toIntOrNull() ?: 0
                val maxStr = (data.getString("player_max", "/ 0") ?: "/ 0").replace("/", "").trim()
                val max = maxStr.toIntOrNull() ?: 0
                cachedStatus = S(on, cur, max)
                isLoading = false
            }
        } catch (_: Exception) {}
    }

    private fun startAnimation(ctx: Context) {
        if (animRunnable != null) return
        val appCtx = ctx.applicationContext
        animRunnable = object : Runnable {
            override fun run() {
                frame++
                if (isLoading) {
                    loadProgress = (loadProgress + 0.15f).coerceAtMost(1f)
                    if (loadProgress >= 1f && System.currentTimeMillis() - lastFetchTime > 2000) {
                        // Keep loading until fetch finishes or times out
                    }
                }

                val mgr = AppWidgetManager.getInstance(appCtx)
                val cn = ComponentName(appCtx, ServerStatusWidgetProvider::class.java)
                val ids = mgr.getAppWidgetIds(cn)
                
                if (ids.isEmpty()) {
                    stopAnimation()
                    return
                }

                for (id in ids) {
                    updateUI(appCtx, mgr, id)
                }

                if (System.currentTimeMillis() - lastFetchTime > FETCH_INTERVAL) {
                    fetchAsync(appCtx)
                }

                handler.postDelayed(this, ANIM_INTERVAL)
            }
        }
        handler.postAtFrontOfQueue(animRunnable!!)
    }

    private fun stopAnimation() {
        animRunnable?.let { handler.removeCallbacks(it) }
        animRunnable = null
    }

    private fun updateUI(ctx: Context, mgr: AppWidgetManager, wid: Int) {
        try {
            val v = RemoteViews(ctx.packageName, R.layout.server_status_widget)
            v.setImageViewBitmap(R.id.widget_image, paint(ctx))
            clicks(ctx, v, wid)
            mgr.updateAppWidget(wid, v)
        } catch (_: Exception) {}
    }

    private fun clicks(ctx: Context, v: RemoteViews, wid: Int) {
        val ri = Intent(ctx, ServerStatusWidgetProvider::class.java).apply {
            action = ACTION_REFRESH
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, wid)
        }
        val pi = PendingIntent.getBroadcast(ctx, wid, ri,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        v.setOnClickPendingIntent(R.id.widget_root, pi)
        v.setOnClickPendingIntent(R.id.widget_image, pi)
    }

    private fun fetchAsync(ctx: Context) {
        if (System.currentTimeMillis() - lastFetchTime < 5000) return 
        lastFetchTime = System.currentTimeMillis()
        Thread {
            try {
                val s = fetch()
                cachedStatus = s
                isLoading = false
                loadProgress = 0f
            } catch (_: Exception) {}
        }.start()
    }

    // ═══════════════════════════════════════════════════════════════
    //  CANVAS ENGINE (Design v2 - HTML Recreation)
    // ═══════════════════════════════════════════════════════════════
    private fun paint(ctx: Context): Bitmap {
        val s = cachedStatus
        val d = ctx.resources.displayMetrics.density
        fun dp(v: Float) = v * d
        fun sp(v: Float) = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, v, ctx.resources.displayMetrics)

        val W = (345 * d).toInt()
        val H = (215 * d).toInt()
        val bmp = Bitmap.createBitmap(W, H, Bitmap.Config.ARGB_8888)
        val c = Canvas(bmp)
        val r = dp(24f)
        val wf = W.toFloat(); val hf = H.toFloat()

        // Animation counters
        val t1 = sin(frame * 0.12).toFloat()
        val t2 = sin(frame * 0.25).toFloat()
        val tNebula = sin(frame * 0.05).toFloat()
        
        // Clip corners
        val clip = Path()
        clip.addRoundRect(RectF(0f, 0f, wf, hf), r, r, Path.Direction.CW)
        c.clipPath(clip)

        val p = Paint().apply { isAntiAlias = true }

        // ── 1. BACKGROUND ──
        if (s.on) {
            val bg = LinearGradient(0f, 0f, wf, hf,
                intArrayOf(0xFF0E1535.toInt(), 0xFF0A0D28.toInt(), 0xFF110820.toInt()),
                floatArrayOf(0f, 0.4f, 1f), Shader.TileMode.CLAMP)
            p.shader = bg; c.drawRect(0f, 0f, wf, hf, p)
            
            // Nebula 1 (Purple - Top Right)
            p.shader = RadialGradient(wf * 0.8f + tNebula * dp(10f), hf * 0.3f, wf * 0.6f,
                0x8C501EC8.toInt(), 0x00000000, Shader.TileMode.CLAMP)
            c.drawRect(0f, 0f, wf, hf, p)
            
            // Nebula 2 (Blue - Bottom Left)
            p.shader = RadialGradient(wf * 0.1f - tNebula * dp(10f), hf * 0.6f, wf * 0.5f,
                0x660050A0.toInt(), 0x00000000, Shader.TileMode.CLAMP)
            c.drawRect(0f, 0f, wf, hf, p)

            // Twinkling Stars
            val starP = Paint().apply { isAntiAlias = true }
            val starLocs = arrayOf(0.1f to 0.15f, 0.3f to 0.1f, 0.5f to 0.25f, 0.8f to 0.12f, 0.9f to 0.2f, 0.2f to 0.35f, 0.6f to 0.08f)
            for ((idx, loc) in starLocs.withIndex()) {
                val shimmer = (sin(frame * 0.2 + idx).toFloat() + 1f) / 2f
                starP.color = Color.argb((50 + 150 * shimmer).toInt(), 200, 220, 255)
                c.drawCircle(wf * loc.first, hf * loc.second, dp(0.8f + shimmer * 0.6f), starP)
            }
        } else {
            val bg = LinearGradient(135f, 0f, wf, hf,
                intArrayOf(0xFF1A0707.toInt(), 0xFF110505.toInt(), 0xFF1A0A08.toInt()),
                floatArrayOf(0f, 0.4f, 1f), Shader.TileMode.CLAMP)
            p.shader = bg; c.drawRect(0f, 0f, wf, hf, p)
            
            // Lava Glow Bottom
            p.shader = RadialGradient(wf * 0.5f, hf, wf * 0.7f,
                0x2EB42800.toInt(), 0x00000000, Shader.TileMode.CLAMP)
            c.drawRect(0f, 0f, wf, hf, p)
        }
        p.shader = null

        // ── 2. CHARACTER ART (Bottom Right) ──
        drawArt(c, s.on, wf, hf, dp(1f), t1, frame)

        // ── 3. SCANLINES ──
        p.color = Color.argb(12, 0, 0, 0); p.strokeWidth = dp(0.8f)
        var ly = 0f; while (ly < hf) { c.drawLine(0f, ly, wf, ly, p); ly += dp(5f) }

        // ── 4. BORDER ──
        p.style = Paint.Style.STROKE; p.strokeWidth = dp(1.5f)
        p.color = if (s.on) 0x3350B4FF.toInt() else 0x33DC3232.toInt()
        c.drawRoundRect(RectF(dp(0.7f), dp(0.7f), wf-dp(0.7f), hf-dp(0.7f)), r, r, p)
        p.style = Paint.Style.FILL

        // ── 5. TOP BAR ──
        val margin = dp(18f)
        var curY = dp(24f)
        
        // Status Dot + Label
        val labelBg = Paint().apply { isAntiAlias = true; color = 0x59000000.toInt() }
        val labelRect = RectF(margin, curY - dp(12f), margin + dp(120f), curY + dp(10f))
        c.drawRoundRect(labelRect, dp(20f), dp(20f), labelBg)
        
        // Pulsing Dot
        val dotPaint = Paint().apply { isAntiAlias = true }
        val dotCol = if (s.on) 0xFF3DFF8A.toInt() else 0xFFFF3D3D.toInt()
        val dotScl = if (s.on) 0.8f + 0.2f * ((t2 + 1f) / 2f) else 1f
        dotPaint.color = Color.argb(100, Color.red(dotCol), Color.green(dotCol), Color.blue(dotCol))
        c.drawCircle(margin + dp(10f), curY - dp(1f), dp(5f) * dotScl, dotPaint)
        dotPaint.color = dotCol
        c.drawCircle(margin + dp(10f), curY - dp(1f), dp(3.5f) * dotScl, dotPaint)
        
        val textP = Paint().apply { isAntiAlias = true; color = 0xD9C8DCFF.toInt(); textSize = sp(10f)
            typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL); letterSpacing = 0.12f }
        c.drawText(ctx.getString(R.string.server_status_label), margin + dp(22f), curY + dp(3f), textP)

        // WiFi Icon / Status Pill (Right)
        val pillX = wf - margin - dp(80f)
        val pillP = Paint().apply { isAntiAlias = true; color = if (s.on) 0x3328B464.toInt() else 0x33B42828.toInt() }
        c.drawRoundRect(RectF(pillX, curY - dp(12f), wf - margin, curY + dp(10f)), dp(20f), dp(20f), pillP)
        textP.color = if (s.on) 0xFF4DFF9A.toInt() else 0xFFFF6060.toInt()
        textP.typeface = Typeface.create("sans-serif-black", Typeface.BOLD); textP.textAlign = Paint.Align.CENTER
        c.drawText(if (s.on) "ONLINE" else "OFFLINE", pillX + dp(40f), curY + dp(3f), textP)
        textP.textAlign = Paint.Align.LEFT

        // ── 6. TITLE ──
        curY += dp(36f)
        textP.textSize = sp(34f); textP.color = Color.WHITE; textP.letterSpacing = -0.01f
        textP.typeface = Typeface.create("sans-serif-black", Typeface.BOLD)
        textP.setShadowLayer(dp(20f), 0f, 0f, if (s.on) 0x4D64A0FF.toInt() else 0x4DFF503C.toInt())
        c.drawText(ctx.getString(R.string.server_name), margin, curY, textP)
        textP.clearShadowLayer()

        // Tagline
        curY += dp(16f)
        textP.textSize = sp(9f); textP.color = if (s.on) 0x9996AADC.toInt() else 0x99966496.toInt()
        textP.typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL); textP.letterSpacing = 0.18f
        c.drawText(ctx.getString(R.string.server_tagline), margin, curY, textP)

        // ── 7. MAIN CONTENT ──
        curY += dp(16f)
        if (isLoading) {
            // Loading Progress Bar
            val barW = wf * 0.5f; val barH = dp(10f)
            val barRect = RectF(margin, curY, margin + barW, curY + barH)
            p.color = 0x22FFFFFF.toInt(); c.drawRoundRect(barRect, dp(5f), dp(5f), p)
            p.shader = LinearGradient(margin, curY, margin + barW * loadProgress, curY,
                intArrayOf(0xFF1A6DFF.toInt(), 0xFF00D2FF.toInt(), 0xFFA855F7.toInt()), null, Shader.TileMode.CLAMP)
            c.drawRoundRect(RectF(margin, curY, margin + barW * loadProgress, curY + barH), dp(5f), dp(5f), p)
            p.shader = null
            textP.textSize = sp(8f); textP.color = 0xCC96C8FF.toInt()
            c.drawText("ESTABLISHING CONNECTION...", margin, curY + barH + dp(12f), textP)
        } else if (s.on) {
            // Players Section
            textP.textSize = sp(8f); textP.color = 0x8078A0DC.toInt()
            c.drawText(ctx.getString(R.string.players_online_label), margin, curY, textP)
            curY += dp(36f)
            textP.textSize = sp(44f); textP.color = 0xFF3DFF8A.toInt()
            textP.setShadowLayer(dp(25f), 0f, 0f, 0x663DFF82.toInt())
            c.drawText("${s.cur}", margin, curY, textP)
            textP.clearShadowLayer()
            val valW = textP.measureText("${s.cur}")
            textP.textSize = sp(20f); textP.color = 0x8064B48C.toInt()
            c.drawText("/ ${s.max}", margin + valW + dp(8f), curY, textP)
            
            // Player avatars shimmer
            curY += dp(14f)
            val avColors = intArrayOf(0xFFC07840.toInt(), 0xFFF0C080.toInt(), 0xFF3AAA3A.toInt(), 0xFFD08040.toInt(), 0xFF8A5A3A.toInt())
            for (idx in 0..4) {
                p.color = avColors[idx]
                c.drawRoundRect(RectF(margin + idx*dp(28f), curY, margin + idx*dp(28f) + dp(22f), curY + dp(22f)), dp(4f), dp(4f), p)
            }
            textP.textSize = sp(9f); textP.color = 0x9996AADC.toInt()
            c.drawText("+${(s.cur-5).coerceAtLeast(0)}", margin + 5*dp(28f) + dp(2f), curY + dp(14f), textP)
        } else {
            // Offline Big Circle X
            val xRadius = dp(24f)
            p.color = 0x26C82828.toInt(); c.drawCircle(margin + xRadius, curY + xRadius, xRadius, p)
            p.style = Paint.Style.STROKE; p.strokeWidth = dp(2.5f); p.color = 0x66DC3C3C.toInt()
            c.drawCircle(margin + xRadius, curY + xRadius, xRadius, p)
            p.style = Paint.Style.FILL; p.color = 0xFFFF4444.toInt()
            val xp = Path(); val xo = margin + xRadius; val yo = curY + xRadius; val sz = dp(8f)
            xp.moveTo(xo-sz, yo-sz); xp.lineTo(xo+sz, yo+sz); xp.moveTo(xo+sz, yo-sz); xp.lineTo(xo-sz, yo+sz)
            c.drawPath(xp, p.apply { style = Paint.Style.STROKE; strokeCap = Paint.Cap.ROUND })
            
            p.style = Paint.Style.FILL
            textP.textSize = sp(34f); textP.color = 0xFFFF4444.toInt()
            textP.typeface = Typeface.create("sans-serif-black", Typeface.BOLD)
            c.drawText("OFFLINE", margin + dp(60f), curY + dp(32f), textP)
            textP.textSize = sp(9f); textP.color = 0x99A05050.toInt()
            c.drawText("LAST SEEN: RECENTLY", margin + dp(60f), curY + dp(48f), textP)
        }

        // ── 8. BOTTOM TABS ──
        val barY = hf - dp(32f)
        p.color = 0x73000000.toInt(); c.drawRect(0f, barY, wf, hf, p)
        p.color = 0x1AFFFFFF.toInt(); p.strokeWidth = dp(0.6f); c.drawLine(0f, barY, wf, barY, p)
        
        // Mode Tabs (World, Survival, PvP)
        val tabP = Paint().apply { isAntiAlias = true; color = if (s.on) 0x66A0B4DC.toInt() else 0x66B46464.toInt()
            textSize = sp(9f); typeface = Typeface.create("sans-serif-bold", Typeface.BOLD) }
        val tabs = arrayOf("World", "Survival", "PvP")
        for (i in 0..2) {
            c.drawText(tabs[i], margin + i*dp(60f), hf - dp(12f), tabP)
        }
        
        // Adventure Tagline (Center)
        tabP.textAlign = Paint.Align.CENTER; tabP.color = if (s.on) 0x8096C8FF.toInt() else 0x80C87878.toInt()
        c.drawText("⚡ YOUR ADVENTURE AWAITS..", wf/2f, barY - dp(8f), tabP)

        return bmp
    }

    private fun drawArt(c: Canvas, online: Boolean, wf: Float, hf: Float, d: Float, t: Float, f: Int) {
        val p = Paint().apply { isAntiAlias = true }
        
        // Castle Silhouette
        p.color = if (online) Color.argb(180, 20, 25, 60) else Color.argb(180, 18, 5, 5)
        val groundY = hf * 0.85f
        c.drawRect(wf * 0.4f, groundY, wf, hf, p) // Ground
        c.drawRect(wf * 0.55f, hf * 0.55f, wf * 0.85f, groundY, p) // Body
        
        // Tower
        val towerPath = Path()
        towerPath.moveTo(wf*0.65f, hf*0.55f); towerPath.lineTo(wf*0.7f, hf*0.35f); towerPath.lineTo(wf*0.75f, hf*0.55f)
        c.drawPath(towerPath, p)
        
        // Characters
        if (online) {
            // Steve
            val sx = wf * 0.85f; val sy = hf * 0.5f
            p.color = 0xFF2A7AC8.toInt(); c.drawRoundRect(RectF(sx-dp(15f, d), sy, sx+dp(15f, d), sy+dp(35f, d)), 4f, 4f, p) // Body
            p.color = 0xFFC07840.toInt(); c.drawRoundRect(RectF(sx-dp(18f, d), sy-dp(20f, d), sx+dp(18f, d), sy), 6f, 6f, p) // Head
            // Creeper
            val cx = wf * 0.72f; val cy = hf * 0.65f
            p.color = 0xFF3AAA3A.toInt(); c.drawRect(cx-dp(12f, d), cy, cx+dp(12f, d), cy+dp(35f, d), p)
            p.color = 0xFF3AAA3A.toInt(); c.drawRect(cx-dp(15f, d), cy-dp(18f, d), cx+dp(15f, d), cy, p)
        } else {
            // Zombie Steve (Ruined)
            val sx = wf * 0.85f; val sy = hf * 0.52f
            p.color = 0xFF5A5A6A.toInt(); c.drawRoundRect(RectF(sx-dp(15f, d), sy, sx+dp(15f, d), sy+dp(35f, d)), 4f, 4f, p) 
            p.color = 0xFF7A6A60.toInt(); c.drawRoundRect(RectF(sx-dp(18f, d), sy-dp(20f, d), sx+dp(18f, d), sy), 6f, 6f, p)
            // Embers
            p.color = Color.argb(180, 255, 100, 0)
            for (idx in 0..3) {
                val cycle = ((f * 0.2 + idx * 2) % 10).toFloat()
                c.drawCircle(wf * (0.6f + idx * 0.1f), hf * (0.4f + cycle * 0.05f), dp(2f, d), p)
            }
        }
    }
x
    private fun dp(v: Float, d: Float) = v * d

    private fun fetch(): S {
        return try {
            val u = URL(API); val c = u.openConnection() as HttpURLConnection
            c.connectTimeout = 5000; c.readTimeout = 5000
            if (c.responseCode == 200) {
                val j = JSONObject(c.inputStream.bufferedReader().readText())
                val pl = j.optJSONObject("players")
                S(j.optBoolean("online", false), pl?.optInt("online", 0) ?: 0, pl?.optInt("max", 0) ?: 0)
            } else S(false, 0, 0)
        } catch (_: Exception) { S(false, 0, 0) }
    }

    data class S(val on: Boolean, val cur: Int, val max: Int)
}
