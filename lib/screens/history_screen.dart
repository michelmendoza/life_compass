import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/activity_log.dart';
import '../data/colors.dart';

class HistoryScreen extends StatefulWidget {
  final List<ActivityLog> logs;
  final VoidCallback onLogsChanged;
  final Function(ActivityLog)? onDeleteLog;

  const HistoryScreen({
    super.key,
    required this.logs,
    required this.onLogsChanged,
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

  List<String> get _availableYears {
    final years = <String>{};
    for (final log in widget.logs) {
      years.add(log.timestamp.year.toString());
    }
    final sorted = years.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  List<String> get _availableMonths {
    if (_selectedYear == null) return [];
    final months = <String>{};
    final year = int.parse(_selectedYear!);
    for (final log in widget.logs) {
      if (log.timestamp.year == year) {
        months.add(log.timestamp.month.toString().padLeft(2, '0'));
      }
    }
    final sorted = months.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  String _monthName(String month) {
    const names = [
      '',
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return names[int.parse(month)];
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
              log.example.toLowerCase().contains(query) ||
              log.energy.toLowerCase().contains(query) ||
              log.flow.toLowerCase().contains(query) ||
              log.organ.toLowerCase().contains(query))
          .toList();
    }

    return result;
  }

  Map<String, List<ActivityLog>> get _groupedLogs {
    final Map<String, List<ActivityLog>> groups = {};
    final sortedLogs = List<ActivityLog>.from(_filteredLogs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    for (final log in sortedLogs) {
      final logDate = log.timestamp;
      final now = DateTime.now();

      String key;
      if (logDate.year == now.year &&
          logDate.month == now.month &&
          logDate.day == now.day) {
        key = 'Hoje - ${DateFormat('dd/MM').format(logDate)}';
      } else if (logDate.year == now.year &&
          logDate.month == now.month &&
          logDate.day == now.day - 1) {
        key = 'Ontem - ${DateFormat('dd/MM').format(logDate)}';
      } else {
        key = DateFormat('EEEE, dd/MM', 'pt_BR').format(logDate);
        key = key[0].toUpperCase() + key.substring(1);
      }

      groups.putIfAbsent(key, () => []).add(log);
    }

    return groups;
  }

  Color _getEnergyColor(String energy) =>
      HawkinsColors.energyColors[energy] ?? Colors.grey;
  Color _getFlowColor(String flow) =>
      HawkinsColors.flowGradient[flow] ?? Colors.grey;
  Color _getOrganColor(String organ) =>
      HawkinsColors.organGradients[organ]?[0] ?? Colors.grey;

  @override
  Widget build(BuildContext context) {
    final groups = _groupedLogs;

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
              _buildSearchAndFilters(),
              Expanded(
                child: _filteredLogs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
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
          child: const Text('📜', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 10),
        Text('Histórico',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A5D23))),
        const Spacer(),
        if (_filteredLogs.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFF6B8E23).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Text(
                '${_filteredLogs.length} registro${_filteredLogs.length > 1 ? 's' : ''}',
                style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B8E23))),
          ),
      ]),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFFA8C686).withOpacity(0.4)),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.lato(
                  fontSize: 12, color: const Color(0xFF4A5D23)),
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle:
                    GoogleFonts.lato(fontSize: 12, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 18, color: Color(0xFF6B8E23)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () => setState(() => _searchQuery = ''),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: Colors.grey),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _buildFilterChip('Todos', 'Todos'),
              _buildFilterChip('Hoje', 'Hoje'),
              _buildFilterChip('Semana', 'Semana'),
              _buildFilterChip('Mês', 'Mês'),
              _buildMonthYearDropdown(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedFilter = filter;
          if (filter != 'Mês/Ano') {
            _selectedYear = null;
            _selectedMonth = null;
          }
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6B8E23).withOpacity(0.15)
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isSelected
                    ? const Color(0xFF6B8E23)
                    : const Color(0xFFA8C686).withOpacity(0.4)),
          ),
          child: Text(label,
              style: GoogleFonts.lato(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected ? const Color(0xFF6B8E23) : Colors.grey[600])),
        ),
      ),
    );
  }

  Widget _buildMonthYearDropdown() {
    final isSelected = _selectedFilter == 'Mês/Ano';
    String label = 'Mês/Ano';
    if (isSelected && _selectedYear != null && _selectedMonth != null) {
      label = '${_monthName(_selectedMonth!)}/${_selectedYear!.substring(2)}';
    } else if (isSelected && _selectedYear != null) {
      label = _selectedYear!;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: _showMonthYearPicker,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6B8E23).withOpacity(0.15)
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isSelected
                    ? const Color(0xFF6B8E23)
                    : const Color(0xFFA8C686).withOpacity(0.4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.calendar_month_rounded,
                size: 14, color: Color(0xFF6B8E23)),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.lato(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF6B8E23)
                        : Colors.grey[600])),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down_rounded,
                size: 16, color: Color(0xFF6B8E23)),
          ]),
        ),
      ),
    );
  }

  void _showMonthYearPicker() {
    String? tempYear = _selectedYear;
    String? tempMonth = _selectedMonth;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Selecionar Mês/Ano',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.close_rounded,
                              size: 18, color: Colors.grey))),
                ]),
                const SizedBox(height: 16),
                Text('Ano',
                    style: GoogleFonts.lato(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[500],
                        letterSpacing: 1.5)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _availableYears.map((year) {
                        final isSelected = tempYear == year;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setModalState(() {
                              tempYear = year;
                              tempMonth = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6B8E23).withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF6B8E23)
                                        : Colors.grey[200]!),
                              ),
                              child: Text(year,
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFF6B8E23)
                                          : Colors.grey[700])),
                            ),
                          ),
                        );
                      }).toList(),
                    )),
                if (tempYear != null) ...[
                  const SizedBox(height: 16),
                  Text('Mês (opcional)',
                      style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey[500],
                          letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _getAvailableMonthsForYear(tempYear!).map((month) {
                        final isSelected = tempMonth == month;
                        return GestureDetector(
                          onTap: () => setModalState(() {
                            tempMonth = isSelected ? null : month;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF6B8E23).withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6B8E23)
                                      : Colors.grey[200]!),
                            ),
                            child: Text(_monthName(month),
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
                      }).toList()),
                ],
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Mês/Ano';
                      _selectedYear = tempYear;
                      _selectedMonth = tempMonth;
                    });
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
                        borderRadius: BorderRadius.circular(15)),
                    child: Text(
                        tempYear != null
                            ? 'APLICAR FILTRO'
                            : 'SELECIONE UM ANO',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1)),
                  ),
                ),
                if (_selectedFilter == 'Mês/Ano')
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = 'Todos';
                        _selectedYear = null;
                        _selectedMonth = null;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text('Limpar filtro',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                                fontSize: 12, color: Colors.red[400]))),
                  ),
              ]),
        ),
      ),
    );
  }

  List<String> _getAvailableMonthsForYear(String yearStr) {
    final months = <String>{};
    final year = int.parse(yearStr);
    for (final log in widget.logs) {
      if (log.timestamp.year == year)
        months.add(log.timestamp.month.toString().padLeft(2, '0'));
    }
    final sorted = months.toList()..sort();
    return sorted;
  }

  Widget _buildDateGroup(String title, List<ActivityLog> logs) {
    final totalDuration =
        logs.fold(Duration.zero, (sum, log) => sum + log.duration);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, top: 10, bottom: 4),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFF6B8E23).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(title,
                style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B8E23))),
          ),
          const SizedBox(width: 6),
          Text('· ${logs.length} ativ. · ${_formatDuration(totalDuration)}',
              style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[400])),
        ]),
      ),
      ...logs.map((log) => _buildCompactCard(log)),
    ]);
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return h > 0 ? '${h}h${m}m' : '${m}m';
  }

  Widget _buildCompactCard(ActivityLog log) {
    final energyColor = _getEnergyColor(log.energy);
    final flowColor = _getFlowColor(log.flow);
    final organColor = _getOrganColor(log.organ);
    final organIcon = log.organ == 'Mente'
        ? '🧠'
        : log.organ == 'Corpo'
            ? '💪'
            : '🧘';
    final energyIcon = log.energy == 'Ativa' ? '⚡' : '🍃';

    // Emoji de consciência
    final consciousnessEmoji = log.consciousnessLevel >= 3
        ? '✨'
        : log.consciousnessLevel >= 2
            ? '🔥'
            : log.consciousnessLevel >= 1
                ? '😐'
                : '';

    // Ícone de dificuldade
    final difficultyIcon = log.difficultyFeedback == 'Fácil'
        ? '🌊'
        : log.difficultyFeedback == 'Médio'
            ? '⚡'
            : log.difficultyFeedback == 'Difícil'
                ? '🔥'
                : '';

    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [Colors.red[400]!, Colors.red[300]!]),
            borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFFF8F9FA),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Text('Excluir?',
                    style: GoogleFonts.playfairDisplay(fontSize: 16)),
                content: Text('"${log.example}"?',
                    style: GoogleFonts.lato(
                        fontSize: 13, color: Colors.grey[600])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar')),
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.red[400]!, Colors.red[300]!]),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Excluir',
                            style: TextStyle(color: Colors.white))),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) {
        print('🗑️ Swipe: ${log.id}');
        if (widget.onDeleteLog != null) {
          widget.onDeleteLog!(log); // Remove do Hive + memória
        } else {
          setState(() => widget.logs.remove(log)); // Fallback
          widget.onLogsChanged();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            // Linha principal
            Padding(
              padding:
                  const EdgeInsets.only(left: 0, right: 4, top: 4, bottom: 0),
              child: Row(
                children: [
                  Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12)),
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [energyColor, flowColor, organColor]))),
                  const SizedBox(width: 8),
                  Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: energyColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(organIcon,
                          style: const TextStyle(fontSize: 14))),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(log.group,
                            style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: const Color(0xFF2D3436)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(log.example,
                            style: GoogleFonts.lato(
                                fontSize: 10, color: Colors.grey[500]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ])),
                  Row(children: [
                    _buildDotChip(energyIcon, energyColor),
                    const SizedBox(width: 2),
                    _buildDotChip('🔄', flowColor),
                  ]),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          energyColor.withOpacity(0.2),
                          energyColor.withOpacity(0.08)
                        ]),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: energyColor.withOpacity(0.25))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.timer_rounded, size: 11, color: energyColor),
                      const SizedBox(width: 3),
                      Text(log.formattedDuration,
                          style: GoogleFonts.lato(
                              color: energyColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11)),
                    ]),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),

            // Linha de feedback (só aparece se tiver dados)
            if (consciousnessEmoji.isNotEmpty || difficultyIcon.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 8, bottom: 4),
                child: Row(
                  children: [
                    if (consciousnessEmoji.isNotEmpty) ...[
                      Text(consciousnessEmoji,
                          style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 2),
                      Text(
                        log.consciousnessLevel >= 3
                            ? 'Fluindo'
                            : log.consciousnessLevel >= 2
                                ? 'Focado'
                                : 'Presente',
                        style: GoogleFonts.lato(
                            fontSize: 9,
                            color: const Color(0xFF6B8E23),
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                    if (consciousnessEmoji.isNotEmpty &&
                        difficultyIcon.isNotEmpty)
                      const SizedBox(width: 8),
                    if (difficultyIcon.isNotEmpty) ...[
                      Text(difficultyIcon,
                          style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 2),
                      Text(log.difficultyFeedback,
                          style: GoogleFonts.lato(
                              fontSize: 9,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500)),
                    ],
                    const Spacer(),
                    if (consciousnessEmoji.isNotEmpty ||
                        difficultyIcon.isNotEmpty)
                      Text('Feedback',
                          style: GoogleFonts.lato(
                              fontSize: 8,
                              color: Colors.grey[400],
                              fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotChip(String text, Color color) {
    return Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: color.withOpacity(0.2))),
        child: Text(text, style: const TextStyle(fontSize: 9)));
  }

  Widget _buildEmptyState() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.35),
              border:
                  Border.all(color: const Color(0xFFA8C686).withOpacity(0.4))),
          child: Icon(Icons.search_off_rounded,
              size: 45, color: Colors.grey[400])),
      const SizedBox(height: 16),
      Text(
          _searchQuery.isNotEmpty
              ? 'Nenhum resultado para\n"$_searchQuery"'
              : 'Nenhuma atividade',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500])),
      const SizedBox(height: 6),
      Text('Tente outro filtro',
          style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[400])),
    ]));
  }
}
