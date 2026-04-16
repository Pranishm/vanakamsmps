// vanakam_widget_provider.dart
// Place in: lib/widgets/
//
// Flutter-side controller for the VANAKAMSMPS Android home screen widget.
// Requires: home_widget: ^0.6.0  (add to pubspec.yaml)
//
// AndroidManifest.xml setup (inside <application>):
//
//   <receiver
//       android:name=".VanakamSMPWidgetProvider"
//       android:exported="true">
//     <intent-filter>
//       <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
//     </intent-filter>
//     <meta-data
//         android:name="android.appwidget.provider"
//         android:resource="@xml/vanakamsmps_widget_info" />
//   </receiver>

import 'package:home_widget/home_widget.dart';

class VanakamWidgetProvider {
  static const String _providerName =
      'com.yourapp.VanakamSMPWidgetProvider'; // update package name

  static const String _onlineLayout  = 'vanakamsmps_widget_online';
  static const String _offlineLayout = 'vanakamsmps_widget_offline';

  /// Push ONLINE state to the home screen widget.
  static Future<void> setOnline({
    required int playerCount,
    required int maxPlayers,
  }) async {
    await Future.wait([
      HomeWidget.saveWidgetData<String>('widget_state',  'online'),
      HomeWidget.saveWidgetData<String>('player_count',  playerCount.toString()),
      HomeWidget.saveWidgetData<String>('player_max',    '/ $maxPlayers'),
      HomeWidget.saveWidgetData<String>('layout_name',   _onlineLayout),
    ]);
    await HomeWidget.updateWidget(
      androidName: _providerName,
    );
  }

  /// Push OFFLINE state to the home screen widget.
  static Future<void> setOffline({String lastSeen = 'RECENTLY'}) async {
    await Future.wait([
      HomeWidget.saveWidgetData<String>('widget_state', 'offline'),
      HomeWidget.saveWidgetData<String>('last_seen',    'LAST SEEN: $lastSeen'),
      HomeWidget.saveWidgetData<String>('layout_name',  _offlineLayout),
    ]);
    await HomeWidget.updateWidget(
      androidName: _providerName,
    );
  }

  /// Register a background callback so the widget can
  /// trigger a server ping when tapped on the home screen.
  static Future<void> registerInteractivity(
    Future<void> Function(Uri? uri) callback,
  ) async {
    await HomeWidget.setAppGroupId('group.vanakamsmps'); // iOS only, safe on Android
    HomeWidget.widgetClicked.listen(callback);
  }
}
