import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:life_compass/screens/onboarding_premium_screen.dart';
import 'package:life_compass/screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/smart_compass_screen.dart';
import 'screens/conscious_action_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'models/activity_log.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ActivityLogAdapter());

  final logsBox = await Hive.openBox('activity_logs');
  final settingsBox = await Hive.openBox('settings');

  await initializeDateFormatting('pt_BR', null);

  // Migra entradas salvas com chave int (box.add) para chave string (log.id)
  await _migrateLogsToIdKeys(logsBox);

  final hasSeenOnboarding =
      settingsBox.get('onboarding_complete', defaultValue: false);

  runApp(LifeCompassApp(
    logsBox: logsBox,
    hasSeenOnboarding: hasSeenOnboarding,
    settingsBox: settingsBox,
  ));
}

Future<void> _migrateLogsToIdKeys(Box logsBox) async {
  final hasIntKeys = logsBox.keys.any((k) => k is int);
  if (!hasIntKeys) return;

  final all = logsBox.values
      .map((e) => ActivityLog.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  await logsBox.clear();
  for (final log in all) {
    await logsBox.put(log.id, log.toJson());
  }
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
      home: hasSeenOnboarding
          ? MainNavigator(logsBox: logsBox, settingsBox: settingsBox)
          : OnboardingPremiumScreen(
              onComplete: () async {
                await settingsBox.put('onboarding_complete', true);

                // ⭐ Recria o app com o novo estado (funcionava antes!)
                runApp(LifeCompassApp(
                  logsBox: logsBox,
                  hasSeenOnboarding: true,
                  settingsBox: settingsBox,
                ));
              },
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

  @override
  void initState() {
    super.initState();

    // FORÇA a HomeScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentIndex = 0;
        });
      }
    });
  }

  Future<void> _addLog(ActivityLog log) async {
    await widget.logsBox.put(log.id, log.toJson());
  }

  Future<void> _removeLog(ActivityLog log) async {
    await widget.logsBox.delete(log.id);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: widget.logsBox.listenable(),
      builder: (context, box, _) {
        final logs = box.values
            .map((e) => ActivityLog.fromJson(Map<String, dynamic>.from(e)))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(
                activityLogs: logs,
                onAddPractice: () => setState(() => _currentIndex = 5),
                onExplore: () => setState(() => _currentIndex = 1),
                onActNow: () => setState(() => _currentIndex = 5),
              ),
              SmartCompassScreen(
                logs: logs,
                onStartActivity: (log) => _addLog(log),
                isSelected: _currentIndex == 1,
              ),
              const SizedBox.shrink(),
              DashboardScreen(
                logs: logs,
              ),
              HistoryScreen(
                logs: logs,
                onDeleteLog: _removeLog,
              ),
              ConsciousActionScreen(
                logs: logs,
                onStartActivity: (log) {
                  if (log != null) _addLog(log);
                  setState(() => _currentIndex = 0);
                },
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex >= 5 ? 2 : _currentIndex,
            onTap: (index) {
              if (index != 2) setState(() => _currentIndex = index);
            },
            backgroundColor: const Color(0xFFF5F9E9),
            selectedItemColor: const Color(0xFF6B8E23),
            unselectedItemColor: Colors.grey[400],
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 8,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Início',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_florist),
                label: 'Match',
              ),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                label: 'Histórico',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => setState(() => _currentIndex = 5),
            backgroundColor: const Color(0xFF8FBC8F),
            elevation: 4,
            shape: const CircleBorder(),
            child: const Text('🌿', style: TextStyle(fontSize: 28)),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}
