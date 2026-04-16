# VANAKAMSMPS Home Screen Widget – Flutter Setup Guide
# =====================================================
#
# File structure to copy into your Flutter project:
#
#   android/app/src/main/res/
#   ├── xml/
#   │   └── vanakamsmps_widget_info.xml
#   ├── layout/
#   │   ├── vanakamsmps_widget_online.xml
#   │   └── vanakamsmps_widget_offline.xml
#   ├── drawable/
#   │   ├── widget_bg_online.xml
#   │   ├── widget_bg_offline.xml
#   │   ├── pill_label_online.xml
#   │   ├── pill_label_offline.xml
#   │   ├── pill_status_online.xml
#   │   ├── pill_status_offline.xml
#   │   ├── dot_online.xml
#   │   ├── dot_online_sm.xml
#   │   ├── dot_offline.xml
#   │   ├── dot_offline_sm.xml
#   │   ├── btn_online.xml
#   │   ├── btn_offline.xml
#   │   ├── bottom_bar_bg.xml
#   │   ├── bottom_bar_bg_offline.xml
#   │   ├── offline_block_bg.xml
#   │   ├── retry_row_bg.xml
#   │   ├── x_circle_bg.xml
#   │   └── ic_x_mark.xml
#   └── values/
#       ├── colors.xml
#       └── strings.xml
#
#   android/app/src/main/kotlin/com/yourapp/
#   └── VanakamSMPWidgetProvider.kt
#
#   lib/widgets/
#   └── vanakam_widget_provider.dart


# ── STEP 1: pubspec.yaml ──────────────────────────────────────────────────────

dependencies:
  home_widget: ^0.6.0


# ── STEP 2: AndroidManifest.xml ──────────────────────────────────────────────
# Add inside <application> in android/app/src/main/AndroidManifest.xml

<!--
<receiver
    android:name=".VanakamSMPWidgetProvider"
    android:exported="true">
  <intent-filter>
    <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
  </intent-filter>
  <meta-data
      android:name="android.appwidget.provider"
      android:resource="@xml/vanakamsmps_widget_info" />
</receiver>
-->


# ── STEP 3: Flutter usage ────────────────────────────────────────────────────

# In your server-pinging service, call:
#
#   import 'package:your_app/widgets/vanakam_widget_provider.dart';
#
#   // When server responds online:
#   await VanakamWidgetProvider.setOnline(
#     playerCount: 143,
#     maxPlayers:  1000,
#   );
#
#   // When server is unreachable:
#   await VanakamWidgetProvider.setOffline(lastSeen: '2 HOURS AGO');


# ── STEP 4: Package name ─────────────────────────────────────────────────────
# Replace "com.yourapp" in VanakamSMPWidgetProvider.kt with your real
# package name (found in android/app/build.gradle → applicationId).


# ── STEP 5: Widget update interval ──────────────────────────────────────────
# vanakamsmps_widget_info.xml sets updatePeriodMillis="1800000" (30 min).
# Android enforces a minimum of 30 minutes for battery reasons.
# For live updates, call VanakamWidgetProvider.setOnline/setOffline
# from your app's background service or WorkManager task instead.


# ── MINIMUM SDK ──────────────────────────────────────────────────────────────
# minSdkVersion 21  (Android 5.0+)
# targetCellWidth / targetCellHeight require API 31+ to take effect;
# minWidth/minHeight are used on older devices automatically.
