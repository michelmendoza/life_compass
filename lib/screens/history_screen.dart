import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/activity_log.dart';
import '../widgets/activity_log_card.dart';
import 'settings_screen.dart';

class HistoryScreen extends StatefulWidget {
  final List<ActivityLog> logs;
  final Function(ActivityLog)? onDeleteLog;

  const HistoryScreen({
    super.key,
    required this.logs,
    this.onDeleteLog,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Todos';
  String? _selectedYear;
  String? _selectedMonth;
  bool _showFilters = false;

  List<String> get _availableYears {
    final years = <String>{};
    for (final log in widget.logs) {
      years.add(log.timestamp.year.toString());
    }
    final sorted = years.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  String _monthName(String month, BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateTime(2000, int.parse(month));
    final name = DateFormat('MMMM', locale).format(date);
    return name[0].toUpperCase() + name.substring(1);
  }

  List<ActivityLog> get _filteredLogs {
    var result = widget.logs;
    final now = DateTime.now();

    switch (_selectedFilter) {
      case 'Hoje':
        result = result
            .where((log) =>
                log.timestamp.day == now.day &&
                log.timestamp.month == now.month &&
                log.timestamp.year == now.year)
            .toList();
        break;
      case 'Semana':
        final weekStart = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        result = result
            .where((log) => log.timestamp
                .isAfter(weekStart.subtract(const Duration(seconds: 1))))
            .toList();
        break;
      case 'Mês':
        result = result
            .where((log) =>
                log.timestamp.month == now.month &&
                log.timestamp.year == now.year)
            .toList();
        break;
      case 'Mês/Ano':
        if (_selectedYear != null && _selectedMonth != null) {
          final year = int.parse(_selectedYear!);
          final month = int.parse(_selectedMonth!);
          result = result
              .where((log) =>
                  log.timestamp.month == month && log.timestamp.year == year)
              .toList();
        } else if (_selectedYear != null) {
          final year = int.parse(_selectedYear!);
          result = result.where((log) => log.timestamp.year == year).toList();
        }
        break;
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((log) =>
              log.group.toLowerCase().contains(query) ||
              log.example.toLowerCase().contains(query))
          .toList();
    }

    return result;
  }

  Map<String, List<ActivityLog>> _getGroupedLogs(BuildContext context) {
    final Map<String, List<ActivityLog>> groups = {};
    final sortedLogs = List<ActivityLog>.from(_filteredLogs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final locale = Localizations.localeOf(context).toLanguageTag();
    final isEn = locale.startsWith('en');
    final now = DateTime.now();

    for (final log in sortedLogs) {
      final logDate = log.timestamp;

      String key;
      if (logDate.year == now.year &&
          logDate.month == now.month &&
          logDate.day == now.day) {
        key = 'Hoje'; // internal key — translated at display time
      } else if (logDate.year == now.year &&
          logDate.month == now.month &&
          logDate.day == now.day - 1) {
        key = 'Ontem'; // internal key — translated at display time
      } else if (logDate.year == now.year) {
        key = isEn
            ? DateFormat('EEEE, MMMM dd', 'en_US').format(logDate)
            : DateFormat("EEEE, dd 'de' MMMM", 'pt_BR').format(logDate);
        key = key[0].toUpperCase() + key.substring(1);
      } else {
        key = isEn
            ? DateFormat('MMMM dd, yyyy', 'en_US').format(logDate)
            : DateFormat("dd 'de' MMMM, yyyy", 'pt_BR').format(logDate);
      }

      groups.putIfAbsent(key, () => []).add(log);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = _getGroupedLogs(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F9E9),
              Color(0xFFEDF4E1),
              Color(0xFFE8F0D5),
              Color(0xFFF0F7E6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              if (_showFilters) _buildFilters(),
              _buildActiveFilters(),
              Expanded(
                child: _filteredLogs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final groupKey = groups.keys.elementAt(index);
                          final groupLogs = groups[groupKey]!;
                          return _buildDateGroup(groupKey, groupLogs);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            ),
            child: const Text('📜', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).historyTitle,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A5D23),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).historySubtitle,
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
              AppLocalizations.of(context).recordsCount(widget.logs.length),
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B8E23),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6B8E23).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.settings_rounded,
                size: 18,
                color: Color(0xFF6B8E23),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: const Color(0xFFA8C686).withOpacity(0.3)),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.lato(
                    fontSize: 14, color: const Color(0xFF2D3436)),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).searchHint,
                  hintStyle:
                      GoogleFonts.lato(fontSize: 13, color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 20, color: Color(0xFF6B8E23)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () => setState(() => _searchQuery = ''),
                          child: const Icon(Icons.close_rounded,
                              size: 18, color: Colors.grey),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _showFilters
                    ? const Color(0xFF6B8E23).withOpacity(0.15)
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _showFilters
                      ? const Color(0xFF6B8E23)
                      : const Color(0xFFA8C686).withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.filter_list_rounded,
                size: 22,
                color:
                    _showFilters ? const Color(0xFF6B8E23) : Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _periodDisplayLabel(String key, AppLocalizations l10n) => switch (key) {
    'Todos' => l10n.filterAll,
    'Hoje' => l10n.filterToday,
    'Semana' => l10n.filterWeek,
    'Mês' => l10n.filterMonth,
    _ => key,
  };

  Widget _buildFilters() {
    final l10n = AppLocalizations.of(context);
    final periods = ['Todos', 'Hoje', 'Semana', 'Mês'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.filterPeriodLabel,
            style: GoogleFonts.lato(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: periods.map((period) {
              final isSelected = _selectedFilter == period;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedFilter = period;
                  if (period != 'Mês/Ano') {
                    _selectedYear = null;
                    _selectedMonth = null;
                  }
                }),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6B8E23)
                        : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : const Color(0xFFA8C686).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    _periodDisplayLabel(period, l10n),
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : const Color(0xFF4A5D23),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _buildMonthYearSelector(),
        ],
      ),
    );
  }

  Widget _buildMonthYearSelector() {
    final l10n = AppLocalizations.of(context);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final isSelected = _selectedFilter == 'Mês/Ano';
    String displayText = l10n.selectPeriodPlaceholder;
    if (isSelected && _selectedYear != null && _selectedMonth != null) {
      final monthStr = _monthName(_selectedMonth!, context);
      displayText = isEn ? '$monthStr $_selectedYear' : '$monthStr de $_selectedYear';
    } else if (isSelected && _selectedYear != null) {
      displayText = _selectedYear!;
    }

    return GestureDetector(
      onTap: _showMonthYearPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6B8E23).withOpacity(0.08)
              : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6B8E23).withOpacity(0.3)
                : const Color(0xFFA8C686).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded,
                size: 20, color: const Color(0xFF6B8E23)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayText,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected ? const Color(0xFF6B8E23) : Colors.grey[600],
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFF6B8E23)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    final hasActiveFilters = _selectedFilter != 'Todos' ||
        _selectedYear != null ||
        _selectedMonth != null ||
        _searchQuery.isNotEmpty;

    if (!hasActiveFilters) return const SizedBox(height: 8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedFilter != 'Todos')
              _activeFilterChip(
                  label: _selectedFilter,
                  onRemove: () => setState(() => _selectedFilter = 'Todos')),
            if (_selectedYear != null)
              _activeFilterChip(
                  label: _selectedYear!,
                  onRemove: () => setState(() => _selectedYear = null)),
            if (_selectedMonth != null)
              _activeFilterChip(
                  label: _monthName(_selectedMonth!, context),
                  onRemove: () => setState(() => _selectedMonth = null)),
            if (_searchQuery.isNotEmpty)
              _activeFilterChip(
                  label: '🔍 $_searchQuery',
                  onRemove: () => setState(() => _searchQuery = '')),
            GestureDetector(
              onTap: () => setState(() {
                _selectedFilter = 'Todos';
                _selectedYear = null;
                _selectedMonth = null;
                _searchQuery = '';
              }),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.clear_rounded,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context).clear,
                        style:
                            GoogleFonts.lato(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeFilterChip(
      {required String label, required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF6B8E23).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: GoogleFonts.lato(
                  fontSize: 11, color: const Color(0xFF6B8E23))),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 14, color: Color(0xFF6B8E23)),
          ),
        ],
      ),
    );
  }

  void _showMonthYearPicker() {
    String? tempYear = _selectedYear;
    String? tempMonth = _selectedMonth;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(l10n.selectPeriodTitle,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(l10n.yearLabel,
                  style: GoogleFonts.lato(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey[500])),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableYears.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, index) {
                    final year = _availableYears[index];
                    final isSelected = tempYear == year;
                    return GestureDetector(
                      onTap: () => setModalState(() {
                        tempYear = year;
                        tempMonth = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6B8E23)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(year,
                            style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700])),
                      ),
                    );
                  },
                ),
              ),
              if (tempYear != null) ...[
                const SizedBox(height: 20),
                Text(l10n.monthOptionalLabel,
                    style: GoogleFonts.lato(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[500])),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getAvailableMonthsForYear(tempYear!).map((month) {
                    final isSelected = tempMonth == month;
                    return GestureDetector(
                      onTap: () => setModalState(
                          () => tempMonth = isSelected ? null : month),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6B8E23).withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6B8E23)
                                  : Colors.grey[200]!),
                        ),
                        child: Text(_monthName(month, context),
                            style: GoogleFonts.lato(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF6B8E23)
                                    : Colors.grey[700])),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(l10n.cancel,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                                fontSize: 14, color: Colors.grey[600])),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'Mês/Ano';
                          _selectedYear = tempYear;
                          _selectedMonth = tempMonth;
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(l10n.apply,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getAvailableMonthsForYear(String yearStr) {
    final months = <String>{};
    final year = int.parse(yearStr);
    for (final log in widget.logs) {
      if (log.timestamp.year == year) {
        months.add(log.timestamp.month.toString().padLeft(2, '0'));
      }
    }
    final sorted = months.toList()..sort();
    return sorted;
  }

  Widget _buildDateGroup(String title, List<ActivityLog> logs) {
    final l10n = AppLocalizations.of(context);
    final totalDuration =
        logs.fold(Duration.zero, (sum, log) => sum + log.duration);
    final isToday = title == 'Hoje';
    final isYesterday = title == 'Ontem';
    final displayTitle = isToday
        ? l10n.today
        : isYesterday
            ? l10n.yesterday
            : title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 16, bottom: 10),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isToday || isYesterday
                      ? const Color(0xFF6B8E23).withOpacity(0.15)
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isToday || isYesterday
                          ? const Color(0xFF6B8E23).withOpacity(0.3)
                          : const Color(0xFFA8C686).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    if (isToday)
                      const Text('🌟', style: TextStyle(fontSize: 12)),
                    if (isYesterday)
                      const Text('📅', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(displayTitle,
                        style: GoogleFonts.lato(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isToday || isYesterday
                                ? const Color(0xFF6B8E23)
                                : const Color(0xFF4A5D23))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                  '${l10n.activityCount(logs.length)} · ${_formatDuration(totalDuration)}',
                  style:
                      GoogleFonts.lato(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ),
        ...logs.map((log) => ActivityLogCard(log: log, onDelete: widget.onDeleteLog)),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}min';
    if (h > 0) return '${h}h';
    return '${m}min';
  }


  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.5),
                border:
                    Border.all(color: const Color(0xFFA8C686).withOpacity(0.4)),
              ),
              child: Icon(
                  _searchQuery.isNotEmpty
                      ? Icons.search_off_rounded
                      : Icons.history_rounded,
                  size: 60,
                  color: Colors.grey[400]),
            ),
            const SizedBox(height: 28),
            Text(
              _searchQuery.isNotEmpty
                  ? l10n.historyEmptyNoResults
                  : l10n.historyEmptyNoActivity,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? l10n.historyEmptySearchHint
                  : l10n.historyEmptyActivityHint,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  fontSize: 14, color: Colors.grey[500], height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
