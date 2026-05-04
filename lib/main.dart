import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:life_compass/screens/onboarding_premium_screen.dart';
import 'package:life_compass/screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/smart_compass_screen.dart';
import 'screens/conscious_action_screen.dart';

import 'models/activity_log.dart';
import 'data/colors.dart';

List<ActivityLog> globalLogs = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ActivityLogAdapter());

  final logsBox = await Hive.openBox('activity_logs');
  final settingsBox =
      await Hive.openBox('settings'); // ← NOVA BOX para configurações

  await initializeDateFormatting('pt_BR', null);

  // Carrega dados salvos
  if (logsBox.isNotEmpty) {
    globalLogs = logsBox.values
        .map((e) => ActivityLog.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // 🔥 Verifica se já viu o onboarding
  final hasSeenOnboarding =
      settingsBox.get('onboarding_complete', defaultValue: false);

  runApp(LifeCompassApp(
    logsBox: logsBox,
    hasSeenOnboarding: hasSeenOnboarding,
    settingsBox: settingsBox,
  ));
}

class ActivityLogAdapter extends TypeAdapter<ActivityLog> {
  @override
  final int typeId = 0;

  @override
  ActivityLog read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return ActivityLog.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, ActivityLog obj) {
    writer.writeMap(obj.toJson());
  }
}

class LifeCompassApp extends StatelessWidget {
  final Box logsBox;
  final bool hasSeenOnboarding;
  final Box settingsBox;

  const LifeCompassApp({
    super.key,
    required this.logsBox,
    required this.hasSeenOnboarding,
    required this.settingsBox,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Compass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: SplashScreen(
        nextScreen: hasSeenOnboarding
            ? MainNavigator(logsBox: logsBox, settingsBox: settingsBox)
            : OnboardingPremiumScreen(
                onComplete: () async {
                  await settingsBox.put('onboarding_complete', true);
                  runApp(LifeCompassApp(
                    logsBox: logsBox,
                    hasSeenOnboarding: true,
                    settingsBox: settingsBox,
                  ));
                },
              ),
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  final Box logsBox;
  final Box settingsBox;

  const MainNavigator({
    super.key,
    required this.logsBox,
    required this.settingsBox,
  });

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  Future<void> _addLog(ActivityLog log) async {
    await widget.logsBox.add(log.toJson());
    setState(() => globalLogs.insert(0, log));
  }

// 🔥 NOVO: Remove do Hive também
  Future<void> _removeLog(ActivityLog log) async {
    print('🗑️ Tentando remover: ${log.id}');

    // Remove do Hive
    for (var i = 0; i < widget.logsBox.length; i++) {
      final data = Map<String, dynamic>.from(widget.logsBox.getAt(i));
      if (data['id'] == log.id) {
        await widget.logsBox.deleteAt(i);
        print('🗑️ Removido do Hive no índice $i');
        break;
      }
    }

    // Remove da memória
    setState(() {
      globalLogs.removeWhere((l) => l.id == log.id);
    });

    print('📦 Total após remoção: ${globalLogs.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ConsciousActionScreen(
            logs: globalLogs,
            onStartActivity: (result) {
              if (result != null && result is ActivityLog) _addLog(result);
            },
          ),
          SmartCompassScreen(
            logs: globalLogs,
            onStartActivity: (log) => _addLog(log),
          ),
          DashboardScreen(
            logs: globalLogs,
            onLogsChanged: () => setState(() {}),
          ),
          HistoryScreen(
            logs: globalLogs,
            onLogsChanged: () => setState(() {}),
            onDeleteLog: _removeLog,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFFF5F9E9),
          selectedItemColor: const Color(0xFF6B8E23),
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(
                icon: Text('🌿', style: TextStyle(fontSize: 20)),
                label: 'Praticar'),
            BottomNavigationBarItem(
                icon: Text('🧭', style: TextStyle(fontSize: 20)),
                label: 'Bússola'),
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded), label: 'Histórico'),
          ],
        ),
      ),
    );
  }
}
