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

  // ========== CÁLCULOS ==========
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

  bool get _isTrendingUp => _totalMinutes > _previousTotalMinutes;
  int get _trendPercent {
    if (_previousTotalMinutes == 0) return 100;
    return ((_totalMinutes - _previousTotalMinutes) /
            _previousTotalMinutes *
            100)
        .round()
        .abs();
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
    if (_filteredLogs.isEmpty) return '📭 Sem dados';
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

  // ========== BUILD ==========
  @override
  Widget build(BuildContext context) {
    final energyBalance = _calculateEnergyBalance();
    final flowDistribution = _calculateFlowDistribution();
    final organBalance = _calculateOrganBalance();
    final categoryDistribution = _calculateCategoryDistribution();

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
              _buildGlassAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildPeriodSelector(),
                      const SizedBox(height: 10),
                      if (_filteredLogs.isNotEmpty) ...[
                        _buildSummaryCard(),
                        const SizedBox(height: 10),
                        _buildSmartSuggestion(),
                        const SizedBox(height: 10),
                        _buildGlassCard(child: _buildEquilibrioCard()),
                        const SizedBox(height: 10),
                        _buildGlassCard(child: _buildConsciousnessCard()),
                        const SizedBox(height: 10),
                        _buildGlassCard(child: _buildFlowVsChallengeCard()),
                        const SizedBox(height: 10),
                        _buildGlassCard(
                            child: _buildEnergyBalance(energyBalance)),
                        const SizedBox(height: 10),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: _buildGlassCard(
                                      child: _buildFlowDistribution(
                                          flowDistribution))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _buildGlassCard(
                                      child: _buildChallengeIndex())),
                            ]),
                        const SizedBox(height: 10),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: _buildGlassCard(
                                      child: _buildOrganBalance(organBalance))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _buildGlassCard(
                                      child: _buildCategoriesSummary(
                                          categoryDistribution))),
                            ]),
                        const SizedBox(height: 10),
                        _buildGlassCard(child: _buildRecentActivities()),
                      ] else
                        _buildEmptyState(),
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

  // ========== WIDGETS ==========

  Widget _buildGlassAppBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F0D5), Color(0xFFF5F9E9), Color(0xFFD4E8C2)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6B8E23).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF6B8E23).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: const Text('🌳', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dashboard Vital',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A5D23))),
          Text('🌿 Métricas da sua jornada',
              style: GoogleFonts.lato(
                  fontSize: 10,
                  color: const Color(0xFF6B8E23).withOpacity(0.7),
                  fontStyle: FontStyle.italic)),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: const Color(0xFF6B8E23).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Text('${widget.logs.length} registros',
              style: GoogleFonts.lato(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B8E23))),
        ),
      ]),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Hoje', 'Semana', 'Mês', 'Geral'];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.4)),
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
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6B8E23).withOpacity(0.8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(period,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        color:
                            isSelected ? Colors.white : const Color(0xFF4A5D23),
                        fontWeight: FontWeight.w600,
                        fontSize: 11)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF6B8E23), Color(0xFF8B6914)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6B8E23).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(children: [
        Row(children: [
          GestureDetector(
            onTap: _canGoBack ? _goBack : null,
            child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(_canGoBack ? 0.2 : 0.05),
                    borderRadius: BorderRadius.circular(6)),
                child: Icon(Icons.chevron_left_rounded,
                    size: 20,
                    color: Colors.white.withOpacity(_canGoBack ? 0.9 : 0.3))),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Column(children: [
            Text(_periodTitle,
                style: GoogleFonts.lato(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2)),
            const SizedBox(height: 2),
            Text(_periodSubtitle,
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ])),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _canGoForward ? _goForward : null,
            child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(_canGoForward ? 0.2 : 0.05),
                    borderRadius: BorderRadius.circular(6)),
                child: Icon(Icons.chevron_right_rounded,
                    size: 20,
                    color:
                        Colors.white.withOpacity(_canGoForward ? 0.9 : 0.3))),
          ),
        ]),
        if (_periodOffset != 0) ...[
          const SizedBox(height: 6),
          GestureDetector(
              onTap: _resetPeriod,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('Voltar ao atual',
                      style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)))),
        ],
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildSummaryItem(
              Icons.timer_rounded, _formatMinutes(_totalMinutes), 'Tempo'),
          _buildSummaryItem(
              Icons.fitness_center_rounded, '$_totalActivities', 'Ativ.'),
          _buildSummaryItem(Icons.auto_awesome_rounded,
              _getLifeBalance().split(' ')[0], 'Estado'),
          _buildSummaryItem(Icons.local_fire_department_rounded,
              '${_currentStreak}d', 'Streak ${_getStreakEmoji()}'),
        ]),
      ]),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(children: [
      Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white, size: 18)),
      const SizedBox(height: 6),
      Text(value,
          style: GoogleFonts.lato(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: GoogleFonts.lato(color: Colors.white70, fontSize: 10)),
    ]);
  }

  Widget _buildSmartSuggestion() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [const Color(0xFFF5F9E9), const Color(0xFFE8F0D5)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.5)),
      ),
      child: Row(children: [
        const Text('💡', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
            child: Text(_getSmartSuggestion(),
                style: GoogleFonts.lato(
                    fontSize: 11,
                    color: const Color(0xFF4A5D23),
                    height: 1.4))),
      ]),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6B8E23).withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _buildEquilibrioCard() {
    final upsCategorias = _upsPorCategoria;
    final naoPraticadas = _categoriasNaoPraticadas;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(_getEquilibrioEmoji(), style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 5),
        Text('EQUILÍBRIO',
            style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey[500],
                letterSpacing: 1.5)),
        const Spacer(),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: _getEquilibrioColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text('${_indiceEquilibrio.round()}%',
                style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getEquilibrioColor()))),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _showInfoModal(
              'Índice de Equilíbrio',
              'Mede quão bem distribuído está seu tempo entre as categorias usando UPs.',
              'UP = Minutos / Tempo ideal\nEquilíbrio = 100% - Variância'),
          child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.info_outline_rounded,
                  size: 12, color: Colors.grey)),
        ),
      ]),
      const SizedBox(height: 10),
      if (upsCategorias.isNotEmpty) ...[
        ...upsCategorias.entries.take(6).map((entry) {
          final maxUP = upsCategorias.values.reduce((a, b) => a > b ? a : b);
          final proporcao = maxUP > 0 ? entry.value / maxUP : 0.0;
          final cor = _getCorCategoria(entry.key);
          return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                SizedBox(
                    width: 80,
                    child: Text(entry.key,
                        style: GoogleFonts.lato(
                            fontSize: 10, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 6),
                Expanded(
                    child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6)),
                        child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: proporcao.clamp(0.05, 1.0),
                            child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [cor, cor.withOpacity(0.7)]),
                                    borderRadius: BorderRadius.circular(6)))))),
                const SizedBox(width: 6),
                SizedBox(
                    width: 35,
                    child: Text('${_formatUPs(entry.value)} UP',
                        style: GoogleFonts.lato(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: cor),
                        textAlign: TextAlign.right)),
              ]));
        }),
      ],
      if (naoPraticadas.isNotEmpty) ...[
        const SizedBox(height: 8),
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.2))),
            child: Row(children: [
              const Text('💡', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(
                      'Não praticado: ${naoPraticadas.take(3).join(", ")}',
                      style: GoogleFonts.lato(
                          fontSize: 10, color: Colors.grey[600])))
            ])),
      ],
      if (_sugestaoEquilibrio.isNotEmpty && _indiceEquilibrio < 70) ...[
        const SizedBox(height: 6),
        Text('Experimente: $_sugestaoEquilibrio',
            style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _getEquilibrioColor())),
      ],
      if (_totalUPs > 0) ...[
        const SizedBox(height: 4),
        Text(
            'Total: ${_formatUPs(_totalUPs)} UPs em $_totalActivities atividades',
            style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[400])),
      ],
    ]);
  }

  Color _getCorCategoria(String categoria) {
    final activity = Activity.activities.firstWhere((a) => a.group == categoria,
        orElse: () => Activity.activities.first);
    return HawkinsColors.energyColors[activity.energy] ??
        const Color(0xFF6B8E23);
  }

  Widget _buildEnergyBalance(Map<String, double> energyBalance) {
    final activePercent = ((energyBalance['Ativa'] ?? 0) * 100).round();
    final passivePercent = ((energyBalance['Passiva'] ?? 0) * 100).round();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.bolt_rounded, size: 13, color: Color(0xFF6B8E23)),
        const SizedBox(width: 5),
        Text('BALANÇO ENERGÉTICO',
            style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey[500],
                letterSpacing: 1.5)),
        const Spacer(),
        GestureDetector(
            onTap: () => _showInfoModal(
                'Balanço Energético',
                'Proporção de TEMPO Ativo vs Passivo.',
                'Minutos do tipo / Total × 100'),
            child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.info_outline_rounded,
                    size: 12, color: Colors.grey))),
        const SizedBox(width: 4),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: const Color(0xFF6B8E23).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6)),
            child: Text(
                '${_isTrendingUp ? "↑" : "↓"}${_trendPercent}% ${_getLifeBalance()}',
                style: GoogleFonts.lato(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B8E23)))),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
            child: _buildBar('⚡ Ativa', energyBalance['Ativa'] ?? 0,
                const Color(0xFFFF6B35), '$activePercent%')),
        const SizedBox(width: 8),
        Expanded(
            child: _buildBar('🍃 Passiva', energyBalance['Passiva'] ?? 0,
                const Color(0xFF4ECDC4), '$passivePercent%')),
      ]),
    ]);
  }

  Widget _buildFlowDistribution(Map<String, double> flowDistribution) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.swap_vert_rounded, size: 13, color: Color(0xFF6B8E23)),
        const SizedBox(width: 5),
        Text('FLOW',
            style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey[500],
                letterSpacing: 1.5)),
        const Spacer(),
        GestureDetector(
            onTap: () => _showInfoModal('Flow', 'Nível de desafio por tempo.',
                'Minutos do nível / Total × 100'),
            child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.info_outline_rounded,
                    size: 12, color: Colors.grey))),
      ]),
      const SizedBox(height: 8),
      ...flowDistribution.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildBar(
              e.key,
              e.value,
              HawkinsColors.flowGradient[e.key] ?? Colors.grey,
              '${(e.value * 100).round()}%'))),
    ]);
  }

  Widget _buildChallengeIndex() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.trending_up_rounded,
            size: 13, color: Color(0xFF6B8E23)),
        const SizedBox(width: 5),
        Text('DESAFIO',
            style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey[500],
                letterSpacing: 1.5)),
        const Spacer(),
        GestureDetector(
            onTap: () => _showInfoModal(
                'Índice de Desafio',
                'Score 0-100 do nível de dificuldade.',
                'Pesos: Fácil=1 a Difícil=5'),
            child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.info_outline_rounded,
                    size: 12, color: Colors.grey))),
      ]),
      const SizedBox(height: 12),
      Center(
          child: Column(children: [
        Stack(alignment: Alignment.center, children: [
          SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                  value: _challengeIndex / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(_challengeIndex > 70
                      ? Colors.red
                      : _challengeIndex > 40
                          ? Colors.orange
                          : const Color(0xFF6B8E23)))),
          Text('$_challengeIndex',
              style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3436))),
        ]),
        const SizedBox(height: 4),
        Text('/100',
            style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[400])),
        const SizedBox(height: 4),
        Text(
            _challengeIndex > 70
                ? '🔥 Alta'
                : _challengeIndex > 40
                    ? '⚡ Moderado'
                    : '🌊 Tranquilo',
            style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[500])),
      ])),
    ]);
  }

  Widget _buildOrganBalance(Map<String, double> organBalance) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.psychology_rounded,
            size: 13, color: Color(0xFF6B8E23)),
        const SizedBox(width: 5),
        Text('FOCO',
            style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey[500],
                letterSpacing: 1.5)),
        const Spacer(),
        GestureDetector(
            onTap: () => _showInfoModal(
                'Foco', 'Tempo por dimensão.', 'Minutos do tipo / Total × 100'),
            child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.info_outline_rounded,
                    size: 12, color: Colors.grey))),
      ]),
      const SizedBox(height: 8),
      ...organBalance.entries.map((e) {
        final icon = e.key == 'Mente'
            ? '🧠'
            : e.key == 'Corpo'
                ? '💪'
                : '🧘';
        return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildBar(
                '$icon ${e.key}',
                e.value,
                HawkinsColors.organGradients[e.key]?[0] ?? Colors.grey,
                '${(e.value * 100).round()}%'));
      }),
    ]);
  }

  Widget _buildCategoriesSummary(Map<String, double> categoryDistribution) {
    final sorted = categoryDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.pie_chart_rounded, size: 13, color: Color(0xFF6B8E23)),
        const SizedBox(width: 5),
        Text('CATEGORIAS',
            style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey[500],
                letterSpacing: 1.5)),
        const Spacer(),
        GestureDetector(
            onTap: () => _showInfoModal('Categorias', 'Top 5 por tempo.',
                'Minutos da categoria / Total × 100'),
            child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.info_outline_rounded,
                    size: 12, color: Colors.grey))),
      ]),
      const SizedBox(height: 8),
      if (top.isEmpty)
        Text('Sem dados',
            style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[400]))
      else
        ...top.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: _buildBar(e.key, e.value, const Color(0xFF6B8E23),
                '${(e.value * 100).round()}%'))),
    ]);
  }

  Widget _buildBar(String label, double value, Color color, String percent) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: GoogleFonts.lato(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500)),
        Text(percent,
            style: GoogleFonts.lato(
                fontSize: 10, color: color, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 3),
      Stack(children: [
        Container(
            height: 5,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3))),
        FractionallySizedBox(
            widthFactor: value,
            child: Container(
                height: 5,
                decoration: BoxDecoration(
                    gradient:
                        LinearGradient(colors: [color, color.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.3), blurRadius: 4)
                    ]))),
      ]),
    ]);
  }

  Widget _buildRecentActivities() {
    final recent = _filteredLogs.take(3).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.history_rounded, size: 13, color: Color(0xFF6B8E23)),
        const SizedBox(width: 5),
        Text('RECENTES',
            style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey[500],
                letterSpacing: 1.5)),
      ]),
      const SizedBox(height: 8),
      ...recent.map((log) {
        final c = HawkinsColors.energyColors[log.energy] ?? Colors.grey;
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Container(
                width: 3,
                height: 22,
                decoration: BoxDecoration(
                    color: c, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Expanded(
                child: Text(log.group,
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold, fontSize: 11))),
            Text(log.formattedDuration,
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold, fontSize: 11, color: c)),
          ]),
        );
      }),
    ]);
  }

  Widget _buildEmptyState() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(height: 40),
      Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.35),
              border:
                  Border.all(color: const Color(0xFFA8C686).withOpacity(0.4))),
          child:
              Icon(Icons.dashboard_rounded, size: 50, color: Colors.grey[400])),
      const SizedBox(height: 16),
      Text('Nenhum dado ainda',
          style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500])),
      const SizedBox(height: 6),
      Text('Inicie uma atividade na Bússola\npara ver suas métricas aqui',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              fontSize: 12, color: Colors.grey[400], height: 1.4)),
      const SizedBox(height: 40),
    ]));
  }

  void _showInfoModal(String title, String description, String formula) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFFA8C686).withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.info_outline_rounded,
                      color: Colors.white, size: 18)),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(title,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3436)))),
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: Colors.grey))),
            ]),
            const SizedBox(height: 16),
            Text(description,
                style: GoogleFonts.lato(
                    fontSize: 13, color: Colors.grey[700], height: 1.5)),
            const SizedBox(height: 12),
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFF5F9E9),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📐 Como é calculado:',
                          style: GoogleFonts.lato(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6B8E23))),
                      const SizedBox(height: 4),
                      Text(formula,
                          style: GoogleFonts.lato(
                              fontSize: 10,
                              color: const Color(0xFF4A5D23),
                              height: 1.4)),
                    ])),
          ]),
        ),
      ),
    );
  }

  // ========== CONSCIÊNCIA MÉDIA ==========

  Widget _buildConsciousnessCard() {
    // Verifica se há dados de feedback
    final logsWithConsciousness =
        _filteredLogs.where((l) => l.consciousnessLevel > 0).toList();

    if (logsWithConsciousness.isEmpty) {
      // Estado vazio: mensagem informativa
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.self_improvement_rounded,
              size: 16, color: Color(0xFF6B8E23)),
          const SizedBox(width: 6),
          Text('CONSCIÊNCIA MÉDIA',
              style: GoogleFonts.lato(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[500],
                  letterSpacing: 1.5)),
          const Spacer(),
          GestureDetector(
            onTap: () => _showInfoModal(
                'Consciência Média',
                'Nível de presença durante as atividades.',
                'Disponível após feedback pós-atividade.'),
            child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5)),
                child: const Icon(Icons.info_outline_rounded,
                    size: 12, color: Colors.grey)),
          ),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xFF6B8E23).withOpacity(0.03),
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Text('📝', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    'Responda o feedback rápido após cada atividade para desbloquear suas métricas de consciência.',
                    style: GoogleFonts.lato(
                        fontSize: 11, color: Colors.grey[500], height: 1.3))),
          ]),
        ),
      ]);
    }

    // TEM DADOS! Mostra o gráfico
    double avgConsciousness = logsWithConsciousness.fold(
            0.0, (sum, l) => sum + l.consciousnessLevel) /
        logsWithConsciousness.length;

    final counts = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};
    for (final log in logsWithConsciousness) {
      counts[log.consciousnessLevel] =
          (counts[log.consciousnessLevel] ?? 0) + 1;
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

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.self_improvement_rounded,
            size: 16, color: Color(0xFF6B8E23)),
        const SizedBox(width: 6),
        Text('CONSCIÊNCIA MÉDIA',
            style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey[500],
                letterSpacing: 1.5)),
        const Spacer(),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFF6B8E23).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text('$emoji $label',
                style: GoogleFonts.lato(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B8E23)))),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _showInfoModal(
              'Consciência Média',
              'Nível de presença durante as atividades.\n\n😴 Automático\n😐 Presente\n🔥 Focado\n✨ Fluindo',
              'Média: Soma dos níveis / Total de feedbacks'),
          child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5)),
              child: const Icon(Icons.info_outline_rounded,
                  size: 12, color: Colors.grey)),
        ),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _consciousnessBar(
            '😴', 0, counts[0] ?? 0, total, const Color(0xFFBDBDBD)),
        const SizedBox(width: 4),
        _consciousnessBar(
            '😐', 1, counts[1] ?? 0, total, const Color(0xFFFFEB3B)),
        const SizedBox(width: 4),
        _consciousnessBar(
            '🔥', 2, counts[2] ?? 0, total, const Color(0xFFFF9800)),
        const SizedBox(width: 4),
        _consciousnessBar(
            '✨', 3, counts[3] ?? 0, total, const Color(0xFF6B8E23)),
      ]),
      const SizedBox(height: 6),
      Text('${logsWithConsciousness.length} atividades com feedback',
          style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[400])),
    ]);
  }

  Widget _consciousnessBar(
      String emoji, int level, int count, int total, Color color) {
    final percent = total > 0 ? count / total : 0.0;
    return Expanded(
      child: Column(children: [
        Text(emoji,
            style: TextStyle(
                fontSize: 18, color: percent > 0 ? color : Colors.grey[300])),
        const SizedBox(height: 2),
        Container(
          height: 4,
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(2)),
          child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percent,
              child: Container(
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(2)))),
        ),
        const SizedBox(height: 2),
        Text('$count',
            style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: percent > 0 ? color : Colors.grey[300])),
      ]),
    );
  }

// ========== FLOW vs DESAFIO (OURO!) ==========
  Widget _buildFlowVsChallengeCard() {
    // Verifica se há dados de feedback
    final logsWithFeedback = _filteredLogs
        .where(
            (l) => l.difficultyFeedback.isNotEmpty && l.consciousnessLevel > 0)
        .toList();

    if (logsWithFeedback.isEmpty) {
      // Estado vazio: mensagem informativa
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.show_chart_rounded,
              size: 16, color: Color(0xFF6B8E23)),
          const SizedBox(width: 6),
          Text('FLOW vs DESAFIO',
              style: GoogleFonts.lato(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[500],
                  letterSpacing: 1.5)),
          const Spacer(),
          GestureDetector(
            onTap: () => _showInfoModal(
                'Flow vs Desafio',
                'Cruza dificuldade com flow.\n\nDescubra sua zona ideal!',
                'Disponível após feedback pós-atividade.'),
            child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5)),
                child: const Icon(Icons.info_outline_rounded,
                    size: 12, color: Colors.grey)),
          ),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xFF6B8E23).withOpacity(0.03),
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Text('🧪', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    'Ao finalizar cada atividade, avalie a dificuldade e seu nível de flow para desbloquear este gráfico.',
                    style: GoogleFonts.lato(
                        fontSize: 11, color: Colors.grey[500], height: 1.3))),
          ]),
        ),
      ]);
    }

    // TEM DADOS! Mostra o gráfico
    int facilFlow = 0, facilNoFlow = 0;
    int medioFlow = 0, medioNoFlow = 0;
    int dificilFlow = 0, dificilNoFlow = 0;

    for (final log in logsWithFeedback) {
      final hasFlow = log.consciousnessLevel >= 3;
      switch (log.difficultyFeedback) {
        case 'Fácil':
          if (hasFlow)
            facilFlow++;
          else
            facilNoFlow++;
          break;
        case 'Médio':
          if (hasFlow)
            medioFlow++;
          else
            medioNoFlow++;
          break;
        case 'Difícil':
          if (hasFlow)
            dificilFlow++;
          else
            dificilNoFlow++;
          break;
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

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.show_chart_rounded,
            size: 16, color: Color(0xFF6B8E23)),
        const SizedBox(width: 6),
        Text('FLOW vs DESAFIO',
            style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey[500],
                letterSpacing: 1.5)),
        const Spacer(),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFF6B8E23).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text('Pico: $bestZone ${(bestRate * 100).round()}%',
                style: GoogleFonts.lato(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B8E23)))),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _showInfoModal(
              'Flow vs Desafio',
              'Cruza dificuldade com flow.\n\nMostra qual zona te leva mais ao flow.',
              'Taxa de Flow = Atividades com ✨ / Total por nível'),
          child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5)),
              child: const Icon(Icons.info_outline_rounded,
                  size: 12, color: Colors.grey)),
        ),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _flowZoneBar('🌊 Fácil', facilFlow, facilTotal, facilRate,
            const Color(0xFF4CAF50)),
        const SizedBox(width: 6),
        _flowZoneBar('⚡ Médio', medioFlow, medioTotal, medioRate,
            const Color(0xFFFFEB3B)),
        const SizedBox(width: 6),
        _flowZoneBar('🔥 Difícil', dificilFlow, dificilTotal, dificilRate,
            const Color(0xFFF44336)),
      ]),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: const Color(0xFF6B8E23).withOpacity(0.05),
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          const Text('💡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
            bestRate > 0.6
                ? 'Você entra em flow principalmente em atividades $bestZone. Este é seu ponto ideal!'
                : bestRate > 0.3
                    ? 'Flow distribuído. Varie a dificuldade para encontrar seu ponto ideal.'
                    : 'Poucos momentos de flow. Tente ajustar: nem tão fácil que entedie, nem tão difícil que frustre.',
            style: GoogleFonts.lato(
                fontSize: 11, color: Colors.grey[700], height: 1.3),
          )),
        ]),
      ),
    ]);
  }

  Widget _flowZoneBar(
      String label, int flowCount, int total, double rate, Color color) {
    return Expanded(
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[600])),
          Text('${(rate * 100).round()}%',
              style: GoogleFonts.lato(
                  fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ]),
        const SizedBox(height: 4),
        Container(
          height: 20,
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
          child: Row(children: [
            if (flowCount > 0)
              Expanded(
                flex: flowCount,
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.8),
                    borderRadius: BorderRadius.horizontal(
                      left: const Radius.circular(4),
                      right: flowCount == total
                          ? const Radius.circular(4)
                          : Radius.zero,
                    ),
                  ),
                  child: Center(
                      child: Text('✨$flowCount',
                          style: GoogleFonts.lato(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                ),
              ),
            if (total - flowCount > 0)
              Expanded(
                flex: total - flowCount,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                          right: const Radius.circular(4))),
                  child: Center(
                      child: Text('${total - flowCount}',
                          style: GoogleFonts.lato(
                              fontSize: 9, color: Colors.grey[400]))),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 2),
        Text('$total atividades',
            style: GoogleFonts.lato(fontSize: 9, color: Colors.grey[400])),
      ]),
    );
  }

  String _getSmartSuggestion() {
    if (_filteredLogs.isEmpty)
      return 'Inicie sua primeira atividade na Bússola para ver insights personalizados! 🚀';
    final naoPraticadas = _categoriasNaoPraticadas;
    final sugestao = _sugestaoEquilibrio;
    if (naoPraticadas.length >= 3)
      return 'Você ainda não praticou ${naoPraticadas.length} categorias. Que tal começar com "$sugestao"? 🌱';
    if (naoPraticadas.length == 1)
      return 'Falta apenas "$sugestao" para diversificar suas práticas! 🎯';
    if (_indiceEquilibrio < 40)
      return 'Seu tempo está concentrado em poucas categorias. Experimente "$sugestao" para equilibrar! ⚖️';
    if (_indiceEquilibrio >= 70)
      return 'Excelente equilíbrio! ${_indiceEquilibrio.round()}% de distribuição entre categorias! ⭐';
    if (_currentStreak >= 7)
      return '${_currentStreak} dias seguidos! ${_formatMinutes(_totalMinutes)} de prática! 🔥';
    return 'Continue variando suas atividades para um desenvolvimento mais completo! 📊';
  }
}
