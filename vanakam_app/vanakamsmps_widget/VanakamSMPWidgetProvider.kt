// VanakamSMPWidgetProvider.kt
// Place in: android/app/src/main/kotlin/com/yourapp/
// (rename package to match your app's package name)
//
// This AppWidgetProvider reads data saved by Flutter's home_widget package
// and switches between the online / offline RemoteViews layout automatically.

package com.yourapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class VanakamSMPWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int
        ) {
            // Read data saved by Flutter via HomeWidget.saveWidgetData()
            val data        = HomeWidgetPlugin.getData(context)
            val state       = data.getString("widget_state", "offline") ?: "offline"
            val playerCount = data.getString("player_count", "0")       ?: "0"
            val playerMax   = data.getString("player_max",   "/ 1000")  ?: "/ 1000"
            val lastSeen    = data.getString("last_seen",    "LAST SEEN: RECENTLY") ?: "LAST SEEN: RECENTLY"

            val views: RemoteViews = if (state == "online") {
                // ── ONLINE layout ──────────────────────────────────────
                RemoteViews(context.packageName, R.layout.vanakamsmps_widget_online).apply {
                    setTextViewText(R.id.tv_player_count, playerCount)
                    setTextViewText(R.id.tv_player_max,   playerMax)
                    setTextViewText(
                        R.id.tv_adventure_tagline,
                        "YOUR ADVENTURE AWAITS.."
                    )
                }
            } else {
                // ── OFFLINE layout ─────────────────────────────────────
                RemoteViews(context.packageName, R.layout.vanakamsmps_widget_offline).apply {
                    setTextViewText(R.id.tv_last_seen, lastSeen)
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
