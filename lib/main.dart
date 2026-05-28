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

import 'models/activity_log.dart';

List<ActivityLog> globalLogs = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ActivityLogAdapter());

  final logsBox = await Hive.openBox('activity_logs');
  final settingsBox = await Hive.openBox('settings');

  await initializeDateFormatting('pt_BR', null);

  // Carrega dados salvos
  if (logsBox.isNotEmpty) {
    globalLogs = logsBox.values
        .map((e) => ActivityLog.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

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
      home: hasSeenOnboarding
          ? MainNavigator(logsBox: logsBox, settingsBox: settingsBox)
          : OnboardingPremiumScreen(
              onComplete: () async {
                print('🟢 ONBOARDING: onComplete CHAMADO!');
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
    print('🔵 MAINNAVIGATOR: initState - _currentIndex = $_currentIndex');

    // FORÇA a HomeScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentIndex = 0;
        });
        print('🔵 MAINNAVIGATOR: FORÇADO _currentIndex = 0');
      }
    });
  }

  Future<void> _addLog(ActivityLog log) async {
    await widget.logsBox.add(log.toJson());
    setState(() => globalLogs.insert(0, log));
  }

  Future<void> _removeLog(ActivityLog log) async {
    print('🗑️ Tentando remover: ${log.id}');

    for (var i = 0; i < widget.logsBox.length; i++) {
      final data = Map<String, dynamic>.from(widget.logsBox.getAt(i));
      if (data['id'] == log.id) {
        await widget.logsBox.deleteAt(i);
        print('🗑️ Removido do Hive no índice $i');
        break;
      }
    }

    setState(() {
      globalLogs.removeWhere((l) => l.id == log.id);
    });

    print('📦 Total após remoção: ${globalLogs.length}');
  }

  @override
  Widget build(BuildContext context) {
    print('🔵 MAINNAVIGATOR: build - _currentIndex = $_currentIndex');
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // HOME SCREEN (índice 0)
          HomeScreen(
            activityLogs: globalLogs,
            onAddPractice: () {
              setState(() => _currentIndex = 5); // Vai para tela de ação
            },
            onExplore: () {
              setState(() => _currentIndex = 1);
            },
            onActNow: () {
              setState(() => _currentIndex = 5); // Vai para tela de ação
            },
          ),
          // SMART COMPASS SCREEN - Bússola (índice 1)
          SmartCompassScreen(
            logs: globalLogs,
            onStartActivity: (log) => _addLog(log),
          ),
          // ESPAÇO VAZIO - índice 2 (não usado, só para espaçamento)
          const SizedBox.shrink(),
          // DASHBOARD SCREEN (índice 3)
          DashboardScreen(
            logs: globalLogs,
            onLogsChanged: () => setState(() {}),
          ),
          // HISTORY SCREEN (índice 4)
          HistoryScreen(
            logs: globalLogs,
            onLogsChanged: () => setState(() {}),
            onDeleteLog: _removeLog,
          ),
          // CONSCIOUS ACTION SCREEN (índice 5)
          ConsciousActionScreen(
            logs: globalLogs,
            onStartActivity: (log) {
              if (log != null) _addLog(log);
              setState(() => _currentIndex = 0); // Volta para Home após salvar
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex >= 5
            ? 2
            : _currentIndex, // Se estiver na tela de ação, marca o índice vazio
        onTap: (index) {
          // Não faz nada se clicar no índice 2 (espaço vazio)
          if (index != 2) {
            setState(() => _currentIndex = index);
          }
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
            icon: Icon(Icons.compass_calibration),
            label: 'Bússola',
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
        onPressed: () {
          setState(() => _currentIndex = 5); // Abre a tela de ação
        },
        child: const Text('🌿', style: TextStyle(fontSize: 28)),
        backgroundColor: const Color(0xFF8FBC8F),
        elevation: 4,
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
