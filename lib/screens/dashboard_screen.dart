import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/activity_log.dart';
import '../data/colors.dart';
import '../data/activities.dart';

class DashboardScreen extends StatefulWidget {
  final List<ActivityLog> logs;
  final VoidCallback onLogsChanged;

  const DashboardScreen({
    super.key,
    required this.logs,
    required this.onLogsChanged,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'Hoje';
  int _periodOffset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugPrintLogs();
    });
  }

  void _debugPrintLogs() {
    print('=== DASHBOARD - TODOS OS LOGS ===');
    for (final log in widget.logs) {
      print('Log: ${log.group} - ${log.formattedDuration}');
      print('  Consciousness: ${log.consciousnessLevel ?? "null"}');
      print('  Difficulty: ${log.difficultyFeedback ?? "null"}');
      print('  Timestamp: ${log.timestamp}');
    }
    print('Total: ${widget.logs.length} logs');

    final withFeedback = widget.logs
        .where((l) => l.consciousnessLevel != null && l.consciousnessLevel! > 0)
        .length;
    print('Logs com feedback de consciência: $withFeedback');
  }

  DateTime get _referenceDate {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Hoje':
        return now.subtract(Duration(days: _periodOffset.abs()));
      case 'Semana':
        return now.subtract(Duration(days: 7 * _periodOffset.abs()));
      case 'Mês':
        int targetMonth = now.month - _periodOffset.abs();
        int targetYear = now.year;
        while (targetMonth <= 0) {
          targetMonth += 12;
          targetYear--;
        }
        return DateTime(targetYear, targetMonth, 15);
      default:
        return now;
    }
  }

  List<ActivityLog> get _filteredLogs {
    final ref = _referenceDate;
    switch (_selectedPeriod) {
      case 'Hoje':
        return widget.logs.where((log) {
          return log.timestamp.day == ref.day &&
              log.timestamp.month == ref.month &&
              log.timestamp.year == ref.year;
        }).toList();
      case 'Semana':
        final weekStart = DateTime(ref.year, ref.month, ref.day)
            .subtract(Duration(days: ref.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        return widget.logs.where((log) {
          final logDate = DateTime(
              log.timestamp.year, log.timestamp.month, log.timestamp.day);
          return !logDate.isBefore(weekStart) && logDate.isBefore(weekEnd);
        }).toList();
      case 'Mês':
        return widget.logs.where((log) {
          return log.timestamp.month == ref.month &&
              log.timestamp.year == ref.year;
        }).toList();
      default:
        return widget.logs;
    }
  }

  List<ActivityLog> get _previousLogs {
    final ref = _referenceDate;
    switch (_selectedPeriod) {
      case 'Hoje':
        final yesterday = ref.subtract(const Duration(days: 1));
        return widget.logs
            .where((log) =>
                log.timestamp.day == yesterday.day &&
                log.timestamp.month == yesterday.month &&
                log.timestamp.year == yesterday.year)
            .toList();
      case 'Semana':
        final thisWeekStart = DateTime(ref.year, ref.month, ref.day)
            .subtract(Duration(days: ref.weekday - 1));
        final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
        return widget.logs
            .where((log) =>
                log.timestamp.isAfter(
                    lastWeekStart.subtract(const Duration(seconds: 1))) &&
                log.timestamp.isBefore(thisWeekStart))
            .toList();
      case 'Mês':
        final lastMonth = ref.month == 1 ? 12 : ref.month - 1;
        final lastMonthYear = ref.month == 1 ? ref.year - 1 : ref.year;
        return widget.logs
            .where((log) =>
                log.timestamp.month == lastMonth &&
                log.timestamp.year == lastMonthYear)
            .toList();
      default:
        return [];
    }
  }

  String get _periodTitle {
    if (_periodOffset == 0) return 'ATUAL';
    if (_periodOffset == -1) return 'ANTERIOR';
    return '${_periodOffset.abs()} ${_selectedPeriod == 'Hoje' ? 'DIAS' : _selectedPeriod == 'Semana' ? 'SEMANAS' : 'MESES'} ATRÁS';
  }

  String get _periodSubtitle {
    final ref = _referenceDate;
    final df = DateFormat('dd/MM');
    switch (_selectedPeriod) {
      case 'Hoje':
        return df.format(ref);
      case 'Semana':
        final weekStart = DateTime(ref.year, ref.month, ref.day)
            .subtract(Duration(days: ref.weekday - 1));
        return '${df.format(weekStart)} - ${df.format(weekStart.add(const Duration(days: 6)))}';
      case 'Mês':
        return DateFormat('MMMM yyyy', 'pt_BR').format(ref);
      default:
        return '';
    }
  }

  bool get _canGoBack => _periodOffset > -12;
  bool get _canGoForward => _periodOffset < 0;
  void _goBack() {
    if (_canGoBack) setState(() => _periodOffset--);
  }

  void _goForward() {
    if (_canGoForward) setState(() => _periodOffset++);
  }

  void _resetPeriod() => setState(() => _periodOffset = 0);

  // ========== UPs ==========
  double _calcularUPs(ActivityLog log) {
    final tempoIdeal = Activity.tempoIdeal[log.group] ?? 60;
    return log.duration.inMinutes / tempoIdeal;
  }

  double get _totalUPs =>
      _filteredLogs.fold(0.0, (sum, log) => sum + _calcularUPs(log));

  Map<String, double> get _upsPorCategoria {
    final map = <String, double>{};
    for (final log in _filteredLogs) {
      map[log.group] = (map[log.group] ?? 0) + _calcularUPs(log);
    }
    return map;
  }

  double get _indiceEquilibrio {
    if (_filteredLogs.isEmpty) return 0;
    final ups = _upsPorCategoria;
    if (ups.length == 1) return 10;
    final valores = ups.values.toList();
    final media = valores.reduce((a, b) => a + b) / valores.length;
    if (media == 0) return 0;
    final somaQuadrados =
        valores.fold(0.0, (sum, v) => sum + (v - media) * (v - media));
    final variancia = somaQuadrados / valores.length;
    final maxVariancia = media * media * (valores.length - 1);
    if (maxVariancia == 0) return 100;
    return ((1 - (variancia / maxVariancia)) * 100)
        .clamp(0.0, 100.0)
        .roundToDouble();
  }

  List<String> get _categoriasNaoPraticadas {
    final praticadas = _upsPorCategoria.keys.toSet();
    return Activity.activities
        .map((a) => a.group)
        .where((g) => !praticadas.contains(g))
        .toList();
  }

  String get _sugestaoEquilibrio {
    final naoPraticadas = _categoriasNaoPraticadas;
    if (naoPraticadas.isNotEmpty) return naoPraticadas.first;
    final ups = _upsPorCategoria;
    if (ups.isNotEmpty)
      return ups.entries.reduce((a, b) => a.value < b.value ? a : b).key;
    return '';
  }

  String _formatUPs(double ups) => ups.toStringAsFixed(1);

  Color _getEquilibrioColor() {
    if (_indiceEquilibrio >= 70) return const Color(0xFF6B8E23);
    if (_indiceEquilibrio >= 40) return const Color(0xFFD4A017);
    return const Color(0xFFC0392B);
  }

  String _getEquilibrioEmoji() {
    if (_indiceEquilibrio >= 80) return '🌳✨';
    if (_indiceEquilibrio >= 60) return '🌿';
    if (_indiceEquilibrio >= 40) return '🍂';
    return '🪵';
  }

  // ========== CÁLCULOS BÁSICOS ==========
  int get _totalMinutes =>
      _filteredLogs.fold(0, (sum, log) => sum + log.duration.inMinutes);
  int get _previousTotalMinutes =>
      _previousLogs.fold(0, (sum, log) => sum + log.duration.inMinutes);
  int get _totalActivities => _filteredLogs.length;

  Map<String, double> _calculateEnergyBalance() {
    if (_filteredLogs.isEmpty || _totalMinutes == 0)
      return {'Ativa': 0, 'Passiva': 0};
    double activeMinutes = 0, passiveMinutes = 0;
    for (final log in _filteredLogs) {
      if (log.energy == 'Ativa')
        activeMinutes += log.duration.inMinutes.toDouble();
      else
        passiveMinutes += log.duration.inMinutes.toDouble();
    }
    return {
      'Ativa': activeMinutes / _totalMinutes,
      'Passiva': passiveMinutes / _totalMinutes
    };
  }

  Map<String, double> _calculateFlowDistribution() {
    if (_filteredLogs.isEmpty || _totalMinutes == 0) return {};
    final Map<String, double> flowMinutes = {};
    for (final log in _filteredLogs) {
      flowMinutes[log.flow] =
          (flowMinutes[log.flow] ?? 0) + log.duration.inMinutes.toDouble();
    }
    return flowMinutes
        .map((key, value) => MapEntry(key, value / _totalMinutes));
  }

  Map<String, double> _calculateOrganBalance() {
    if (_filteredLogs.isEmpty || _totalMinutes == 0) return {};
    final Map<String, double> organMinutes = {};
    for (final log in _filteredLogs) {
      organMinutes[log.organ] =
          (organMinutes[log.organ] ?? 0) + log.duration.inMinutes.toDouble();
    }
    return organMinutes
        .map((key, value) => MapEntry(key, value / _totalMinutes));
  }

  Map<String, double> _calculateCategoryDistribution() {
    if (_filteredLogs.isEmpty || _totalMinutes == 0) return {};
    final Map<String, double> catMinutes = {};
    for (final log in _filteredLogs) {
      catMinutes[log.group] =
          (catMinutes[log.group] ?? 0) + log.duration.inMinutes.toDouble();
    }
    return catMinutes.map((key, value) => MapEntry(key, value / _totalMinutes));
  }

  int get _challengeIndex {
    if (_filteredLogs.isEmpty || _totalMinutes == 0) return 0;
    double weightedSum = 0;
    for (final log in _filteredLogs) {
      int weight;
      switch (log.flow) {
        case 'Fácil':
          weight = 1;
          break;
        case 'Fácil – Médio':
          weight = 2;
          break;
        case 'Médio':
          weight = 3;
          break;
        case 'Médio – Difícil':
          weight = 4;
          break;
        case 'Difícil':
          weight = 5;
          break;
        default:
          weight = 1;
      }
      weightedSum += weight * log.duration.inMinutes;
    }
    return ((weightedSum / (_totalMinutes * 5)) * 100).round();
  }

  int get _currentStreak {
    if (widget.logs.isEmpty) return 0;
    final sortedLogs = List<ActivityLog>.from(widget.logs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    int streak = 0;
    DateTime checkDate = DateTime.now();
    for (final log in sortedLogs) {
      final logDate =
          DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      final checkDay = DateTime(checkDate.year, checkDate.month, checkDate.day);
      if (logDate == checkDay) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (logDate.isBefore(checkDay)) break;
    }
    return streak;
  }

  List<int> get _last7DaysMinutes {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return widget.logs
          .where((log) =>
              log.timestamp.day == day.day &&
              log.timestamp.month == day.month &&
              log.timestamp.year == day.year)
          .fold(0, (sum, log) => sum + log.duration.inMinutes);
    });
  }

  String _getDayLabel(int weekday) {
    const labels = {1: 'Seg', 2: 'Ter', 3: 'Qua', 4: 'Qui', 5: 'Sex', 6: 'Sáb', 7: 'Dom'};
    return labels[weekday] ?? '';
  }

  bool get _isTrendingUp => _totalMinutes > _previousTotalMinutes;
  int get _trendPercent {
    if (_previousTotalMinutes == 0) return 100;
    return ((_totalMinutes - _previousTotalMinutes).abs() /
            _previousTotalMinutes *
            100)
        .round();
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return hours > 0 ? '${hours}h${mins}m' : '${mins}m';
  }

  String _getLifeBalance() {
    final energy = _calculateEnergyBalance();
    final active = energy['Ativa'] ?? 0;
    final passive = energy['Passiva'] ?? 0;
    if (_filteredLogs.isEmpty) return 'Sem dados';
    if (active > 0.7) return '🔥 Muito Ativo';
    if (passive > 0.7) return '🧘 Contemplativo';
    if (active >= 0.4 && passive >= 0.4) return '⚖️ Equilibrado';
    if (active > passive) return '⚡ Tend. Ativa';
    return '🌿 Tend. Passiva';
  }

  String _getStreakEmoji() {
    if (_currentStreak >= 30) return '👑';
    if (_currentStreak >= 14) return '🔥';
    if (_currentStreak >= 7) return '⭐';
    if (_currentStreak >= 3) return '💪';
    return _currentStreak >= 1 ? '🌱' : '';
  }

  // ========== BUILD PRINCIPAL ==========
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F9E9),
              Color(0xFFE8F0D5),
              Color(0xFFF0F7E6),
              Color(0xFFD4E8C2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildPeriodSelector(),
                      const SizedBox(height: 20),
                      if (_filteredLogs.isEmpty)
                        _buildEmptyState()
                      else ...[
                        _buildHeroStatsCard(),
                        const SizedBox(height: 16),
                        _buildEquilibrioCard(),
                        const SizedBox(height: 16),
                        _buildSmartSuggestion(),
                        const SizedBox(height: 16),
                        _buildConsciousnessCard(),
                        const SizedBox(height: 16),
                        _buildFlowVsChallengeCard(),
                        const SizedBox(height: 16),
                        _buildEnergyBalanceCard(),
                        const SizedBox(height: 16),
                        _buildFlowDistributionCard(),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildChallengeIndexCard()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildOrganBalanceCard()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCategoriesCard(),
                        const SizedBox(height: 16),
                        _buildRecentActivitiesCard(),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== HEADER ==========
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F0D5), Color(0xFFF5F9E9), Color(0xFFD4E8C2)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B8E23).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B8E23), Color(0xFF8B6914)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B8E23).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Text('🌳', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Vital',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A5D23),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sua jornada de evolução consciente',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: const Color(0xFF6B8E23).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6B8E23).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.logs.length} registros',
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B8E23),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== SELETOR DE PERÍODO ==========
  Widget _buildPeriodSelector() {
    final periods = ['Hoje', 'Semana', 'Mês', 'Geral'];
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.3)),
          ),
          child: Row(
            children: periods.map((period) {
              final isSelected = _selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedPeriod = period;
                    _periodOffset = 0;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6B8E23)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Text(
                      period,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF4A5D23),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedPeriod != 'Geral')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navArrow(Icons.chevron_left_rounded, _canGoBack, _goBack),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _periodTitle,
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey[500],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _periodSubtitle,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4A5D23),
                        ),
                      ),
                    ],
                  ),
                ),
                _navArrow(
                    Icons.chevron_right_rounded, _canGoForward, _goForward),
              ],
            ),
          ),
        if (_periodOffset != 0 && _selectedPeriod != 'Geral')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: _resetPeriod,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E23).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Voltar ao atual',
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B8E23),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _navArrow(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF6B8E23).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 24,
          color: enabled ? const Color(0xFF6B8E23) : Colors.grey[300],
        ),
      ),
    );
  }

  // ========== CARD PRINCIPAL ==========
  Widget _buildHeroStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B8E23), Color(0xFF8B6914)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B8E23).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _heroStatItem(
                icon: Icons.timer_rounded,
                value: _formatMinutes(_totalMinutes),
                label: 'Tempo total',
              ),
              _heroStatItem(
                icon: Icons.fitness_center_rounded,
                value: '$_totalActivities',
                label: 'Atividades',
              ),
              _heroStatItem(
                icon: Icons.local_fire_department_rounded,
                value: '${_currentStreak}d',
                label: 'Sequência',
                suffix: _getStreakEmoji(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.trending_up_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLifeBalance(),
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getTrendText(),
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_totalMinutes > 0 && _previousTotalMinutes > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isTrendingUp
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_trendPercent%',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildWeeklySparkline(),
        ],
      ),
    );
  }

  Widget _heroStatItem({
    required IconData icon,
    required String value,
    required String label,
    String suffix = '',
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 10),
        Text(
          '$value$suffix',
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 11,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  String _getTrendText() {
    if (_previousTotalMinutes == 0) return 'Primeiros registros! 🎉';
    if (_isTrendingUp) return '${_trendPercent}% mais que período anterior';
    return '${_trendPercent}% menos que período anterior';
  }

  Widget _buildWeeklySparkline() {
    final minutes = _last7DaysMinutes;
    final maxMin = minutes.reduce((a, b) => a > b ? a : b);
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: Colors.white.withOpacity(0.2)),
        const SizedBox(height: 12),
        Text(
          'ÚLTIMOS 7 DIAS',
          style: GoogleFonts.lato(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white60,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final day = today.subtract(Duration(days: 6 - i));
            final mins = minutes[i];
            final proportion = maxMin > 0 ? mins / maxMin : 0.0;
            final isToday = i == 6;
            final barHeight = proportion > 0
                ? (proportion * 36).clamp(4.0, 36.0)
                : 3.0;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (mins > 0)
                      Text(
                        _formatMinutes(mins),
                        style: GoogleFonts.lato(
                          fontSize: 8,
                          color: isToday
                              ? Colors.white
                              : Colors.white.withOpacity(0.55),
                        ),
                      ),
                    const SizedBox(height: 3),
                    Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: mins > 0
                            ? (isToday
                                ? Colors.white
                                : Colors.white.withOpacity(0.5))
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDayLabel(day.weekday),
                      style: GoogleFonts.lato(
                        fontSize: 9,
                        color: isToday
                            ? Colors.white
                            : Colors.white.withOpacity(0.55),
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ========== CARD DE EQUILÍBRIO ==========
  Widget _buildEquilibrioCard() {
    final upsCategorias = _upsPorCategoria;
    final naoPraticadas = _categoriasNaoPraticadas;
    final maxUP = upsCategorias.values.isEmpty
        ? 1
        : upsCategorias.values.reduce((a, b) => a > b ? a : b);

    return _glassCard(
      title: 'Equilíbrio entre Categorias',
      icon: Icons.balance_rounded,
      rightWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _getEquilibrioColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${_indiceEquilibrio.round()}% ${_getEquilibrioEmoji()}',
          style: GoogleFonts.lato(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _getEquilibrioColor(),
          ),
        ),
      ),
      child: Column(
        children: [
          ...upsCategorias.entries.take(5).map((entry) {
            final proporcao = maxUP > 0 ? entry.value / maxUP : 0.0;
            final cor = _getCorCategoria(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${_formatUPs(entry.value)} UP',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: proporcao.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(cor),
                    borderRadius: BorderRadius.circular(6),
                    minHeight: 8,
                  ),
                ],
              ),
            );
          }),
          if (naoPraticadas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Não praticado: ${naoPraticadas.take(3).join(", ")}',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_sugestaoEquilibrio.isNotEmpty && _indiceEquilibrio < 70)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '✨ Experimente: $_sugestaoEquilibrio',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getEquilibrioColor(),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${_formatUPs(_totalUPs)} UPs em $_totalActivities atividades',
                style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[500]),
              ),
              Text(
                '* barras relativas ao maior valor',
                style: GoogleFonts.lato(fontSize: 9, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCorCategoria(String categoria) {
    final activity = Activity.activities.firstWhere((a) => a.group == categoria,
        orElse: () => Activity.activities.first);
    return HawkinsColors.energyColors[activity.energy] ??
        const Color(0xFF6B8E23);
  }

  // ========== CARD DE CONSCIÊNCIA ==========
  Widget _buildConsciousnessCard() {
    // CORRIGIDO: verifica null
    final logsWithConsciousness = _filteredLogs
        .where((l) => l.consciousnessLevel != null && l.consciousnessLevel! > 0)
        .toList();

    if (logsWithConsciousness.isEmpty) {
      return _glassCard(
        title: 'Consciência Média',
        icon: Icons.self_improvement_rounded,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6B8E23).withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('📝', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Responda o feedback rápido após cada atividade para desbloquear suas métricas de consciência.',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // CORRIGIDO: usa ! porque já verificou que não é null
    double avgConsciousness = logsWithConsciousness.fold(
            0.0, (sum, l) => sum + (l.consciousnessLevel ?? 0)) /
        logsWithConsciousness.length;

    final counts = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};
    for (final log in logsWithConsciousness) {
      final level = log.consciousnessLevel ?? 0;
      counts[level] = (counts[level] ?? 0) + 1;
    }

    final total = logsWithConsciousness.length;
    final emoji = avgConsciousness >= 3
        ? '✨'
        : avgConsciousness >= 2
            ? '🔥'
            : avgConsciousness >= 1
                ? '😐'
                : '😴';
    final label = avgConsciousness >= 3
        ? 'Fluindo'
        : avgConsciousness >= 2
            ? 'Focado'
            : avgConsciousness >= 1
                ? 'Presente'
                : 'Automático';

    return _glassCard(
      title: 'Consciência Média',
      icon: Icons.self_improvement_rounded,
      rightWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF6B8E23).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$emoji $label',
          style: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B8E23),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _consciousnessBar('😴', 0, counts[0] ?? 0, total, const Color(0xFFE57373)),
              const SizedBox(width: 8),
              _consciousnessBar(
                  '😐', 1, counts[1] ?? 0, total, const Color(0xFFFFEB3B)),
              const SizedBox(width: 8),
              _consciousnessBar(
                  '🔥', 2, counts[2] ?? 0, total, const Color(0xFFFF9800)),
              const SizedBox(width: 8),
              _consciousnessBar(
                  '✨', 3, counts[3] ?? 0, total, const Color(0xFF6B8E23)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('← mais automático',
                  style: GoogleFonts.lato(fontSize: 9, color: Colors.grey[400])),
              Text('mais consciente →',
                  style: GoogleFonts.lato(fontSize: 9, color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${logsWithConsciousness.length} atividades com feedback',
            style: GoogleFonts.lato(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _consciousnessBar(
      String emoji, int level, int count, int total, Color color) {
    final percent = total > 0 ? count / total : 0.0;
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: percent > 0 ? color : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // ========== CARD FLOW vs DESAFIO ==========
  Widget _buildFlowVsChallengeCard() {
    // CORRIGIDO: verifica null
    final logsWithFeedback = _filteredLogs
        .where((l) =>
            l.difficultyFeedback != null &&
            l.difficultyFeedback!.isNotEmpty &&
            l.consciousnessLevel != null &&
            l.consciousnessLevel! > 0)
        .toList();

    if (logsWithFeedback.isEmpty) {
      return _glassCard(
        title: 'Flow vs Desafio',
        icon: Icons.show_chart_rounded,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6B8E23).withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('🧪', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ao finalizar cada atividade, avalie a dificuldade e seu nível de flow para desbloquear este gráfico.',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    int facilFlow = 0, facilNoFlow = 0;
    int medioFlow = 0, medioNoFlow = 0;
    int dificilFlow = 0, dificilNoFlow = 0;

    for (final log in logsWithFeedback) {
      final hasFlow = (log.consciousnessLevel ?? 0) >= 3;
      final difficulty = log.difficultyFeedback ?? '';

      if (difficulty == 'Fácil') {
        if (hasFlow)
          facilFlow++;
        else
          facilNoFlow++;
      } else if (difficulty == 'Difícil') {
        if (hasFlow)
          dificilFlow++;
        else
          dificilNoFlow++;
      } else {
        if (hasFlow)
          medioFlow++;
        else
          medioNoFlow++;
      }
    }

    final facilTotal = facilFlow + facilNoFlow;
    final medioTotal = medioFlow + medioNoFlow;
    final dificilTotal = dificilFlow + dificilNoFlow;
    final facilRate = facilTotal > 0 ? facilFlow / facilTotal : 0.0;
    final medioRate = medioTotal > 0 ? medioFlow / medioTotal : 0.0;
    final dificilRate = dificilTotal > 0 ? dificilFlow / dificilTotal : 0.0;

    String bestZone;
    double bestRate;
    if (medioRate >= facilRate && medioRate >= dificilRate) {
      bestZone = 'Médio';
      bestRate = medioRate;
    } else if (dificilRate >= facilRate) {
      bestZone = 'Difícil';
      bestRate = dificilRate;
    } else {
      bestZone = 'Fácil';
      bestRate = facilRate;
    }

    return _glassCard(
      title: 'Flow vs Desafio',
      icon: Icons.show_chart_rounded,
      rightWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF6B8E23).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Pico: $bestZone ${(bestRate * 100).round()}%',
          style: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B8E23),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _flowZoneBar('🌊 Fácil', facilFlow, facilTotal, facilRate,
                  const Color(0xFF4CAF50)),
              const SizedBox(width: 8),
              _flowZoneBar('⚡ Médio', medioFlow, medioTotal, medioRate,
                  const Color(0xFFFFC107)),
              const SizedBox(width: 8),
              _flowZoneBar('🔥 Difícil', dificilFlow, dificilTotal, dificilRate,
                  const Color(0xFFF44336)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6B8E23).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    bestRate > 0.6
                        ? 'Você entra em flow principalmente em atividades $bestZone. Este é seu ponto ideal!'
                        : bestRate > 0.3
                            ? 'Flow distribuído. Varie a dificuldade para encontrar seu ponto ideal.'
                            : 'Poucos momentos de flow. Tente ajustar: nem tão fácil que entedie, nem tão difícil que frustre.',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _flowZoneBar(
      String label, int flowCount, int total, double rate, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (flowCount > 0)
                  Expanded(
                    flex: flowCount,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.8),
                        borderRadius: BorderRadius.horizontal(
                          left: const Radius.circular(8),
                          right: flowCount == total
                              ? const Radius.circular(8)
                              : Radius.zero,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '✨$flowCount',
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (total - flowCount > 0)
                  Expanded(
                    flex: total - flowCount,
                    child: Center(
                      child: Text(
                        '${total - flowCount}',
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$total ativ.',
            style: GoogleFonts.lato(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(rate * 100).round()}% flow',
            style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ========== CARD ENERGIA ==========
  Widget _buildEnergyBalanceCard() {
    final energyBalance = _calculateEnergyBalance();
    final activePercent = ((energyBalance['Ativa'] ?? 0) * 100).round();
    final passivePercent = ((energyBalance['Passiva'] ?? 0) * 100).round();

    return _glassCard(
      title: 'Balanço Energético',
      icon: Icons.bolt_rounded,
      child: Row(
        children: [
          Expanded(
            child:
                _energyPill('⚡ Ativa', activePercent, const Color(0xFFFF6B35)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _energyPill(
                '🍃 Passiva', passivePercent, const Color(0xFF4ECDC4)),
          ),
        ],
      ),
    );
  }

  Widget _energyPill(String label, int percent, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percent%',
            style: GoogleFonts.lato(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(6),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  // ========== CARD FLOW DISTRIBUTION ==========
  Widget _buildFlowDistributionCard() {
    final flowDistribution = _calculateFlowDistribution();

    return _glassCard(
      title: 'Distribuição do Flow',
      icon: Icons.swap_vert_rounded,
      child: Column(
        children: flowDistribution.entries.map((entry) {
          final color = HawkinsColors.flowGradient[entry.key] ?? Colors.grey;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${(entry.value * 100).round()}%',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: entry.value,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(6),
                  minHeight: 6,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ========== CARD CHALLENGE INDEX ==========
  Widget _buildChallengeIndexCard() {
    return _glassCard(
      title: 'Índice de Desafio',
      icon: Icons.trending_up_rounded,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: _challengeIndex / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _challengeIndex > 70
                        ? const Color(0xFFF44336)
                        : _challengeIndex > 40
                            ? const Color(0xFFFFC107)
                            : const Color(0xFF6B8E23),
                  ),
                ),
              ),
              Text(
                '$_challengeIndex',
                style: GoogleFonts.lato(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _challengeIndex > 70
                ? '🔥 Alta intensidade'
                : _challengeIndex > 40
                    ? '⚡ Moderado'
                    : '🌊 Fluxo tranquilo',
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '0 = Suave · 100 = Intenso',
            style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ========== CARD ÓRGÃOS ==========
  Widget _buildOrganBalanceCard() {
    final organBalance = _calculateOrganBalance();
    final organs = ['Mente', 'Corpo', 'Espírito'];
    final icons = {'Mente': '🧠', 'Corpo': '💪', 'Espírito': '🧘'};

    return _glassCard(
      title: 'Foco por Dimensão',
      icon: Icons.psychology_rounded,
      child: Column(
        children: organs.map((organ) {
          final percent = ((organBalance[organ] ?? 0) * 100).round();
          final color = HawkinsColors.organGradients[organ]?[0] ?? Colors.grey;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$organ ${icons[organ]}',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: percent / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(6),
                  minHeight: 8,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ========== CARD CATEGORIAS ==========
  Widget _buildCategoriesCard() {
    final categoryDistribution = _calculateCategoryDistribution();
    final sorted = categoryDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();

    final rows = <Widget>[];
    for (var i = 0; i < top.length; i += 2) {
      final left = top[i];
      final right = i + 1 < top.length ? top[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Expanded(child: _categoryBar(left)),
              if (right != null) ...[
                const SizedBox(width: 16),
                Expanded(child: _categoryBar(right)),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    return _glassCard(
      title: 'Top Categorias',
      icon: Icons.pie_chart_rounded,
      child: Column(children: rows),
    );
  }

  Widget _categoryBar(MapEntry<String, double> entry) {
    final color = _getCorCategoria(entry.key);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                entry.key,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${(entry.value * 100).round()}%',
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: entry.value,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(6),
          minHeight: 6,
        ),
      ],
    );
  }

  // ========== CARD ATIVIDADES RECENTES ==========
  Widget _buildRecentActivitiesCard() {
    final limit = _selectedPeriod == 'Hoje'
        ? 10
        : _selectedPeriod == 'Semana'
            ? 10
            : _selectedPeriod == 'Mês'
                ? 15
                : 20;
    final sorted = List<ActivityLog>.from(_filteredLogs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final recent = sorted.take(limit).toList();

    return _glassCard(
      title: 'Atividades Recentes',
      icon: Icons.history_rounded,
      child: Column(
        children: recent.map((log) {
          final color = HawkinsColors.energyColors[log.energy] ?? Colors.grey;
          final dateFormat = DateFormat('dd/MM - HH:mm');
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.group,
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        log.example,
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      log.formattedDuration,
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(log.timestamp),
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ========== CARD SUGESTÃO INTELIGENTE ==========
  Widget _buildSmartSuggestion() {
    String suggestion;
    if (_filteredLogs.isEmpty) {
      suggestion =
          'Inicie sua primeira atividade na Bússola para ver insights personalizados! 🚀';
    } else {
      final naoPraticadas = _categoriasNaoPraticadas;
      final sugestao = _sugestaoEquilibrio;
      if (naoPraticadas.length >= 3) {
        suggestion =
            'Você ainda não praticou ${naoPraticadas.length} categorias. Que tal começar com "$sugestao"? 🌱';
      } else if (naoPraticadas.length == 1) {
        suggestion =
            'Falta apenas "$sugestao" para diversificar suas práticas! 🎯';
      } else if (_indiceEquilibrio < 40) {
        suggestion =
            'Seu tempo está concentrado em poucas categorias. Experimente "$sugestao" para equilibrar! ⚖️';
      } else if (_indiceEquilibrio >= 70) {
        suggestion =
            'Excelente equilíbrio! ${_indiceEquilibrio.round()}% de distribuição entre categorias! ⭐';
      } else if (_currentStreak >= 7) {
        suggestion =
            '${_currentStreak} dias seguidos! ${_formatMinutes(_totalMinutes)} de prática! 🔥';
      } else {
        suggestion =
            'Continue variando suas atividades para um desenvolvimento mais completo! 📊';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFF5F9E9), const Color(0xFFE8F0D5)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestion,
              style: GoogleFonts.lato(
                fontSize: 13,
                color: const Color(0xFF4A5D23),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== CARD GENÉRICO ==========
  Widget _glassCard({
    required String title,
    required IconData icon,
    Widget? rightWidget,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B8E23).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: const Color(0xFF6B8E23)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[500],
                    letterSpacing: 1.2,
                  ),
                  maxLines: 2,
                  softWrap: true,
                ),
              ),
              if (rightWidget != null) ...[
                const SizedBox(width: 8),
                rightWidget,
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ========== ESTADO VAZIO ==========
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.7),
              border:
                  Border.all(color: const Color(0xFFA8C686).withOpacity(0.4)),
            ),
            child: Icon(
              Icons.dashboard_rounded,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nenhuma atividade neste período',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Altere o período ou inicie uma atividade\nna Bússola para ver suas métricas',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 13,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
