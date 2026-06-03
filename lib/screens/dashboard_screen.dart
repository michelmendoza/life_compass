import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/activity_log.dart';
import '../data/activities.dart';
import '../l10n/app_localizations.dart';
import '../l10n/domain_translations.dart';
import '../widgets/dashboard/categories_card.dart';
import '../widgets/dashboard/challenge_index_card.dart';
import '../widgets/dashboard/consciousness_card.dart';
import '../widgets/dashboard/empty_state.dart';
import '../widgets/dashboard/energy_balance_card.dart';
import '../widgets/dashboard/equilibrio_card.dart';
import '../widgets/dashboard/flow_challenge_card.dart';
import '../widgets/dashboard/flow_distribution_card.dart';
import '../widgets/dashboard/hero_stats_card.dart';
import '../widgets/dashboard/organ_balance_card.dart';
import '../widgets/dashboard/recent_activities_card.dart';
import '../widgets/dashboard/smart_suggestion.dart';

class DashboardScreen extends StatefulWidget {
  final List<ActivityLog> logs;

  const DashboardScreen({super.key, required this.logs});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'Hoje';
  int _periodOffset = 0;

  // ========== PERÍODO ==========

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
        return widget.logs.where((log) =>
            log.timestamp.day == ref.day &&
            log.timestamp.month == ref.month &&
            log.timestamp.year == ref.year).toList();
      case 'Semana':
        final weekStart = DateTime(ref.year, ref.month, ref.day)
            .subtract(Duration(days: ref.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        return widget.logs.where((log) {
          final logDate = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
          return !logDate.isBefore(weekStart) && logDate.isBefore(weekEnd);
        }).toList();
      case 'Mês':
        return widget.logs.where((log) =>
            log.timestamp.month == ref.month &&
            log.timestamp.year == ref.year).toList();
      default:
        return widget.logs;
    }
  }

  List<ActivityLog> get _previousLogs {
    final ref = _referenceDate;
    switch (_selectedPeriod) {
      case 'Hoje':
        final yesterday = ref.subtract(const Duration(days: 1));
        return widget.logs.where((log) =>
            log.timestamp.day == yesterday.day &&
            log.timestamp.month == yesterday.month &&
            log.timestamp.year == yesterday.year).toList();
      case 'Semana':
        final thisWeekStart = DateTime(ref.year, ref.month, ref.day)
            .subtract(Duration(days: ref.weekday - 1));
        final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
        return widget.logs.where((log) =>
            log.timestamp.isAfter(lastWeekStart.subtract(const Duration(seconds: 1))) &&
            log.timestamp.isBefore(thisWeekStart)).toList();
      case 'Mês':
        final lastMonth = ref.month == 1 ? 12 : ref.month - 1;
        final lastMonthYear = ref.month == 1 ? ref.year - 1 : ref.year;
        return widget.logs.where((log) =>
            log.timestamp.month == lastMonth &&
            log.timestamp.year == lastMonthYear).toList();
      default:
        return [];
    }
  }

  String _getPeriodTitle(AppLocalizations l10n) {
    if (_periodOffset == 0) return l10n.periodCurrent;
    if (_periodOffset == -1) return l10n.periodPrevious;
    final count = _periodOffset.abs();
    if (_selectedPeriod == 'Hoje') return l10n.periodDaysAgo(count);
    if (_selectedPeriod == 'Semana') return l10n.periodWeeksAgo(count);
    return l10n.periodMonthsAgo(count);
  }

  String _getPeriodSubtitle(BuildContext context) {
    final ref = _referenceDate;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final df = DateFormat('dd/MM');
    switch (_selectedPeriod) {
      case 'Hoje':
        return df.format(ref);
      case 'Semana':
        final weekStart = DateTime(ref.year, ref.month, ref.day)
            .subtract(Duration(days: ref.weekday - 1));
        return '${df.format(weekStart)} - ${df.format(weekStart.add(const Duration(days: 6)))}';
      case 'Mês':
        return DateFormat('MMMM yyyy', locale).format(ref);
      default:
        return '';
    }
  }

  bool get _canGoBack => _periodOffset > -12;
  bool get _canGoForward => _periodOffset < 0;
  void _goBack() { if (_canGoBack) setState(() => _periodOffset--); }
  void _goForward() { if (_canGoForward) setState(() => _periodOffset++); }
  void _resetPeriod() => setState(() => _periodOffset = 0);

  // ========== UPs ==========

  double _calcularUPs(ActivityLog log) {
    final tempoIdeal = Activity.tempoIdeal[log.group] ?? 60;
    return log.duration.inMinutes / tempoIdeal;
  }

  double get _totalUPs => _filteredLogs.fold(0.0, (sum, log) => sum + _calcularUPs(log));

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
    final somaQuadrados = valores.fold(0.0, (sum, v) => sum + (v - media) * (v - media));
    final variancia = somaQuadrados / valores.length;
    final maxVariancia = media * media * (valores.length - 1);
    if (maxVariancia == 0) return 100;
    return ((1 - (variancia / maxVariancia)) * 100).clamp(0.0, 100.0).roundToDouble();
  }

  List<String> get _categoriasNaoPraticadas {
    final praticadas = _upsPorCategoria.keys.toSet();
    return Activity.activities.map((a) => a.group).where((g) => !praticadas.contains(g)).toList();
  }

  String get _sugestaoEquilibrio {
    final naoPraticadas = _categoriasNaoPraticadas;
    if (naoPraticadas.isNotEmpty) return naoPraticadas.first;
    final ups = _upsPorCategoria;
    if (ups.isNotEmpty) return ups.entries.reduce((a, b) => a.value < b.value ? a : b).key;
    return '';
  }

  // ========== CÁLCULOS ==========

  int get _totalMinutes => _filteredLogs.fold(0, (sum, log) => sum + log.duration.inMinutes);
  int get _previousTotalMinutes => _previousLogs.fold(0, (sum, log) => sum + log.duration.inMinutes);
  int get _totalActivities => _filteredLogs.length;

  Map<String, double> _calculateEnergyBalance() {
    if (_filteredLogs.isEmpty || _totalMinutes == 0) return {'Ativa': 0, 'Passiva': 0};
    double activeMinutes = 0, passiveMinutes = 0;
    for (final log in _filteredLogs) {
      if (log.energy == 'Ativa') activeMinutes += log.duration.inMinutes.toDouble();
      else passiveMinutes += log.duration.inMinutes.toDouble();
    }
    return {'Ativa': activeMinutes / _totalMinutes, 'Passiva': passiveMinutes / _totalMinutes};
  }

  Map<String, double> _calculateFlowDistribution() {
    if (_filteredLogs.isEmpty || _totalMinutes == 0) return {};
    final Map<String, double> flowMinutes = {};
    for (final log in _filteredLogs) {
      flowMinutes[log.flow] = (flowMinutes[log.flow] ?? 0) + log.duration.inMinutes.toDouble();
    }
    return flowMinutes.map((key, value) => MapEntry(key, value / _totalMinutes));
  }

  Map<String, double> _calculateOrganBalance() {
    if (_filteredLogs.isEmpty || _totalMinutes == 0) return {};
    final Map<String, double> organMinutes = {};
    for (final log in _filteredLogs) {
      organMinutes[log.organ] = (organMinutes[log.organ] ?? 0) + log.duration.inMinutes.toDouble();
    }
    return organMinutes.map((key, value) => MapEntry(key, value / _totalMinutes));
  }

  Map<String, double> _calculateCategoryDistribution() {
    if (_filteredLogs.isEmpty || _totalMinutes == 0) return {};
    final Map<String, double> catMinutes = {};
    for (final log in _filteredLogs) {
      catMinutes[log.group] = (catMinutes[log.group] ?? 0) + log.duration.inMinutes.toDouble();
    }
    return catMinutes.map((key, value) => MapEntry(key, value / _totalMinutes));
  }

  int get _challengeIndex {
    if (_filteredLogs.isEmpty || _totalMinutes == 0) return 0;
    double weightedSum = 0;
    for (final log in _filteredLogs) {
      int weight;
      switch (log.flow) {
        case 'Fácil': weight = 1; break;
        case 'Fácil – Médio': weight = 2; break;
        case 'Médio': weight = 3; break;
        case 'Médio – Difícil': weight = 4; break;
        case 'Difícil': weight = 5; break;
        default: weight = 1;
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
      final logDate = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
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

  bool get _isTrendingUp => _totalMinutes > _previousTotalMinutes;
  int get _trendPercent {
    if (_previousTotalMinutes == 0) return 100;
    return ((_totalMinutes - _previousTotalMinutes).abs() / _previousTotalMinutes * 100).round();
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return hours > 0 ? '${hours}h${mins}m' : '${mins}m';
  }

  String _getLifeBalance(AppLocalizations l10n) {
    final energy = _calculateEnergyBalance();
    final active = energy['Ativa'] ?? 0;
    final passive = energy['Passiva'] ?? 0;
    if (_filteredLogs.isEmpty) return l10n.statusNoData;
    if (active > 0.7) return l10n.statusVeryActive;
    if (passive > 0.7) return l10n.statusContemplative;
    if (active >= 0.4 && passive >= 0.4) return l10n.statusBalanced;
    if (active > passive) return l10n.statusTendingActive;
    return l10n.statusTendingPassive;
  }

  String _getStreakEmoji() {
    if (_currentStreak >= 30) return '👑';
    if (_currentStreak >= 14) return '🔥';
    if (_currentStreak >= 7) return '⭐';
    if (_currentStreak >= 3) return '💪';
    return _currentStreak >= 1 ? '🌱' : '';
  }

  String _getTrendText(AppLocalizations l10n) {
    if (_previousTotalMinutes == 0) return l10n.trendFirstRecords;
    if (_isTrendingUp) return l10n.trendUp(_trendPercent);
    return l10n.trendDown(_trendPercent);
  }

  String _getSmartSuggestion(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_filteredLogs.isEmpty) return l10n.suggestionStart;
    final naoPraticadas = _categoriasNaoPraticadas;
    final sugestao = DomainTranslations.category(context, _sugestaoEquilibrio);
    if (naoPraticadas.length >= 3) {
      return l10n.suggestionMultipleCategories(naoPraticadas.length, sugestao);
    } else if (naoPraticadas.length == 1) {
      return l10n.suggestionOneCategory(sugestao);
    } else if (_indiceEquilibrio < 40) {
      return l10n.suggestionLowBalance(sugestao);
    } else if (_indiceEquilibrio >= 70) {
      return l10n.suggestionHighBalance(_indiceEquilibrio.round());
    } else if (_currentStreak >= 7) {
      return l10n.suggestionStreak(_currentStreak, _formatMinutes(_totalMinutes));
    }
    return l10n.suggestionVary;
  }

  // ========== BUILD ==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F9E9), Color(0xFFE8F0D5),
              Color(0xFFF0F7E6), Color(0xFFD4E8C2),
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
                        const DashboardEmptyState()
                      else ...[
                        HeroStatsCard(
                          totalMinutes: _totalMinutes,
                          totalActivities: _totalActivities,
                          currentStreak: _currentStreak,
                          streakEmoji: _getStreakEmoji(),
                          lifeBalance: _getLifeBalance(AppLocalizations.of(context)),
                          trendText: _getTrendText(AppLocalizations.of(context)),
                          isTrendingUp: _isTrendingUp,
                          trendPercent: _trendPercent,
                          showTrend: _totalMinutes > 0 && _previousTotalMinutes > 0,
                          last7DaysMinutes: _last7DaysMinutes,
                        ),
                        const SizedBox(height: 16),
                        EquilibrioCard(
                          upsPorCategoria: _upsPorCategoria,
                          indiceEquilibrio: _indiceEquilibrio,
                          categoriasNaoPraticadas: _categoriasNaoPraticadas,
                          sugestaoEquilibrio: _sugestaoEquilibrio,
                          totalUPs: _totalUPs,
                          totalActivities: _totalActivities,
                        ),
                        const SizedBox(height: 16),
                        SmartSuggestion(suggestion: _getSmartSuggestion(context)),
                        const SizedBox(height: 16),
                        ConsciousnessCard(filteredLogs: _filteredLogs),
                        const SizedBox(height: 16),
                        FlowVsChallengeCard(filteredLogs: _filteredLogs),
                        const SizedBox(height: 16),
                        EnergyBalanceCard(energyBalance: _calculateEnergyBalance()),
                        const SizedBox(height: 16),
                        FlowDistributionCard(flowDistribution: _calculateFlowDistribution()),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: ChallengeIndexCard(challengeIndex: _challengeIndex)),
                            const SizedBox(width: 16),
                            Expanded(child: OrganBalanceCard(organBalance: _calculateOrganBalance())),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CategoriesCard(categoryDistribution: _calculateCategoryDistribution()),
                        const SizedBox(height: 16),
                        RecentActivitiesCard(
                          filteredLogs: _filteredLogs,
                          selectedPeriod: _selectedPeriod,
                        ),
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
          BoxShadow(color: const Color(0xFF6B8E23).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: const Color(0xFF6B8E23).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: const Text('🌳', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).dashboardTitle, style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF4A5D23))),
                const SizedBox(height: 4),
                Text(AppLocalizations.of(context).dashboardSubtitle, style: GoogleFonts.lato(fontSize: 13, color: const Color(0xFF6B8E23).withOpacity(0.7))),
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
              AppLocalizations.of(context).recordsCount(widget.logs.length),
              style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B8E23)),
            ),
          ),
        ],
      ),
    );
  }

  // ========== SELETOR DE PERÍODO ==========

  String _periodLabel(String key, AppLocalizations l10n) => switch (key) {
    'Hoje' => l10n.periodToday,
    'Semana' => l10n.periodWeek,
    'Mês' => l10n.periodMonth,
    'Geral' => l10n.periodAll,
    _ => key,
  };

  Widget _buildPeriodSelector() {
    final l10n = AppLocalizations.of(context);
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
                  onTap: () => setState(() { _selectedPeriod = period; _periodOffset = 0; }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6B8E23) : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Text(
                      _periodLabel(period, l10n),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF4A5D23),
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
                      Text(_getPeriodTitle(AppLocalizations.of(context)), style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[500], letterSpacing: 1.2)),
                      const SizedBox(height: 2),
                      Text(_getPeriodSubtitle(context), style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF4A5D23))),
                    ],
                  ),
                ),
                _navArrow(Icons.chevron_right_rounded, _canGoForward, _goForward),
              ],
            ),
          ),
        if (_periodOffset != 0 && _selectedPeriod != 'Geral')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: _resetPeriod,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E23).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(l10n.backToCurrent, style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF6B8E23))),
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
          color: enabled ? const Color(0xFF6B8E23).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 24, color: enabled ? const Color(0xFF6B8E23) : Colors.grey[300]),
      ),
    );
  }
}
