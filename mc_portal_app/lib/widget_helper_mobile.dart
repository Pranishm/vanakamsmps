import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class WidgetHelper {
  static void init() {
    try {
      HomeWidget.setAppGroupId('group.mc_portal_app');
    } catch (e) {
      debugPrint('HomeWidget init error: $e');
    }
  }

  static Future<void> saveData(String status, int players, int maxPlayers, int admins) async {
    try {
      await HomeWidget.saveWidgetData<String>('server_status', status);
      await HomeWidget.saveWidgetData<int>('players_count', players);
      await HomeWidget.saveWidgetData<int>('max_players', maxPlayers);
      await HomeWidget.saveWidgetData<int>('admins_count', admins);
      await HomeWidget.updateWidget(
        name: 'MinecraftWidgetProvider',
        androidName: 'MinecraftWidgetProvider',
        iOSName: 'MinecraftWidget',
      );
    } catch (e) {
      debugPrint('HomeWidget save error: $e');
    }
  }
}
