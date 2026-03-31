package com.example.mc_portal_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import com.example.mc_portal_app.R

class MinecraftWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val serverStatus = widgetData.getString("server_status", "Checking...")
                val players = widgetData.getInt("players_count", 0)
                val maxPlayers = widgetData.getInt("max_players", 100)

                setTextViewText(R.id.widget_server_status, "Status: $serverStatus")
                setTextViewText(R.id.widget_players, "Players: $players / $maxPlayers")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
