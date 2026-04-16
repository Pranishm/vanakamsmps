// vanakam_widget_provider.dart
// Flutter-side controller for the VANAKAMSMPS Android home screen widget.
// Uses home_widget package to push data from Flutter to the native widget.

import 'package:home_widget/home_widget.dart';

class VanakamWidgetProvider {
  static const String _providerName =
      'me.vanakam.vanakam_app.ServerStatusWidgetProvider';

  /// Push ONLINE state to the home screen widget.
  static Future<void> setOnline({
    required int playerCount,
    required int maxPlayers,
  }) async {
    await Future.wait([
      HomeWidget.saveWidgetData<String>('widget_state', 'online'),
      HomeWidget.saveWidgetData<String>('player_count', playerCount.toString()),
      HomeWidget.saveWidgetData<String>('player_max', '/ $maxPlayers'),
    ]);
    await HomeWidget.updateWidget(
      androidName: _providerName,
    );
  }

  /// Push OFFLINE state to the home screen widget.
  static Future<void> setOffline({String lastSeen = 'RECENTLY'}) async {
    await Future.wait([
      HomeWidget.saveWidgetData<String>('widget_state', 'offline'),
      HomeWidget.saveWidgetData<String>('last_seen', 'LAST SEEN: $lastSeen'),
    ]);
    await HomeWidget.updateWidget(
      androidName: _providerName,
    );
  }

  /// Register interactivity so tap events from the widget
  /// can trigger actions in the Flutter app.
  static Future<void> registerInteractivity(
    Future<void> Function(Uri? uri) callback,
  ) async {
    await HomeWidget.setAppGroupId('group.vanakamsmps');
    HomeWidget.widgetClicked.listen(callback);
  }
}
