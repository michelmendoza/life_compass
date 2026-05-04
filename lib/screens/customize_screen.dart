import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/activities.dart';
import '../data/colors.dart';
import '../data/custom_activities.dart';
import '../data/practice.dart';

class CustomizeScreen extends StatefulWidget {
  final VoidCallback onActivitiesChanged;

  const CustomizeScreen({super.key, required this.onActivitiesChanged});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  List<Activity> _allActivities = [];
  List<Map<String, dynamic>> _customData = [];
  bool _loading = true;

  // Lista fixa das 9 categorias padrão
  final List<Activity> _defaultActivities = Activity.activities;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final activities = await CustomActivitiesManager.loadActivities();
    final custom = await CustomActivitiesManager.getCustomActivities();
    if (mounted) {
      setState(() {
        _allActivities = activities;
        _customData = custom;
        _loading = false;
      });
    }
  }

  /// Separa customizadas das padrão
  List<Activity> get _customActivities {
    final customNames = _customData.map((c) => c['group'] as String).toSet();
    return _allActivities.where((a) => customNames.contains(a.group)).toList();
  }

  /// Apenas as padrão originais (não modificadas)
  List<Activity> get _defaultOnly {
    final customNames = _customData.map((c) => c['group'] as String).toSet();
    return _defaultActivities
        .where((a) => !customNames.contains(a.group))
        .toList();
  }

  int _getCustomIndex(Activity activity) {
    return _customData.indexWhere((c) => c['group'] == activity.group);
  }

  // ========== AÇÕES ==========

  void _addNewCategory() {
    showDialog(
      context: context,
      builder: (_) => _CategoryFormDialog(onSave: (activity) async {
        await CustomActivitiesManager.addCustomActivity(activity);
        await _loadData();
        widget.onActivitiesChanged();
      }),
    );
  }

  void _editCategory(Activity activity) {
    final index = _getCustomIndex(activity);
    if (index < 0) return;
    final data = _customData[index];
    showDialog(
      context: context,
      builder: (_) => _CategoryFormDialog(
        initialData: data,
        onSave: (updated) async {
          await CustomActivitiesManager.updateCustomActivity(index, updated);
          await _loadData();
          widget.onActivitiesChanged();
        },
      ),
    );
  }

  void _deleteCategory(Activity activity) {
    final index = _getCustomIndex(activity);
    if (index < 0) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF8F9FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            Text('Remover?', style: GoogleFonts.playfairDisplay(fontSize: 16)),
        content: Text('A categoria "${activity.group}" será removida.',
            style: GoogleFonts.lato(fontSize: 13, color: Colors.grey[600])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.red[400]!, Colors.red[300]!]),
                borderRadius: BorderRadius.circular(10)),
            child: TextButton(
                onPressed: () async {
                  await CustomActivitiesManager.removeCustomActivity(index);
                  await _loadData();
                  widget.onActivitiesChanged();
                  Navigator.pop(ctx);
                },
                child: const Text('Remover',
                    style: TextStyle(color: Colors.white))),
          ),
        ],
      ),
    );
  }

  void _addPractice(Activity activity) {
    showDialog(
      context: context,
      builder: (_) => _PracticeFormDialog(
        categoryName: activity.group,
        onSave: (practice) async {
          final updated = List<Practice>.from(activity.practices)
            ..add(practice);
          final updatedActivity = Activity(
              group: activity.group, icon: activity.icon, practices: updated);

          final existingIndex =
              _customData.indexWhere((c) => c['group'] == activity.group);
          if (existingIndex >= 0) {
            await CustomActivitiesManager.updateCustomActivity(
                existingIndex, updatedActivity);
          } else {
            await CustomActivitiesManager.addCustomActivity(updatedActivity);
          }
          await _loadData();
          widget.onActivitiesChanged();
        },
      ),
    );
  }

  // ========== BUILD ==========

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xFFF5F9E9),
            Color(0xFFE8F0D5),
            Color(0xFFF0F7E6),
            Color(0xFFD4E8C2)
          ]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ===== MINHAS CATEGORIAS =====
                    _sectionHeader('✨ MINHAS CATEGORIAS', 'Nova Categoria',
                        _addNewCategory),
                    const SizedBox(height: 8),
                    if (_customActivities.isEmpty)
                      _emptyCard(
                          'Nenhuma categoria personalizada.\nToque em "Nova Categoria" para criar!')
                    else
                      ..._customActivities
                          .map((a) => _buildCard(a, isCustom: true)),

                    const SizedBox(height: 24),

                    // ===== CATEGORIAS PADRÃO =====
                    _sectionHeader('📦 CATEGORIAS PADRÃO', null, null),
                    const SizedBox(height: 8),
                    ..._defaultOnly.map((a) => _buildCard(a, isCustom: false)),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String? buttonText, VoidCallback? onTap) {
    return Row(children: [
      Text(title,
          style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.grey[600],
              letterSpacing: 1.5)),
      const Spacer(),
      if (buttonText != null && onTap != null)
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
                borderRadius: BorderRadius.circular(15)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(buttonText,
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
            ]),
          ),
        ),
    ]);
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.3))),
      child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  fontSize: 12, color: Colors.grey[400], height: 1.5))),
    );
  }

  Widget _buildCard(Activity activity, {required bool isCustom}) {
    final practice =
        activity.practices.isNotEmpty ? activity.practices.first : null;
    final color = practice != null
        ? (HawkinsColors.energyColors[practice.energy] ?? Colors.grey)
        : Colors.grey;
    final flowColor = practice != null
        ? (HawkinsColors.flowGradient[practice.flow] ?? Colors.grey)
        : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.3)),
      ),
      child: Column(children: [
        // Card principal
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(colors: [color, flowColor]))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Text(activity.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(activity.group,
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xFF2D3436))),
                  ]),
                  const SizedBox(height: 4),
                  Text('${activity.practices.length} prática(s)',
                      style: GoogleFonts.lato(
                          fontSize: 10, color: Colors.grey[500])),
                ])),
            // 🔥 EDITAR sempre disponível (padrão ou customizada)
            GestureDetector(
              onTap: () {
                if (isCustom) {
                  _editCategory(activity);
                } else {
                  _editDefaultCategory(activity);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: const Color(0xFF6B8E23).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit_rounded,
                    size: 16, color: Color(0xFF6B8E23)),
              ),
            ),
            // 🔥 DELETAR só nas customizadas
            if (isCustom) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _deleteCategory(activity),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 16, color: Colors.red),
                ),
              ),
            ],
          ]),
        ),
        // Botão + Prática
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF6B8E23).withOpacity(0.03),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: GestureDetector(
            onTap: () => _addPractice(activity),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add_rounded,
                    size: 14, color: Color(0xFF6B8E23)),
                const SizedBox(width: 4),
                Text('Adicionar prática',
                    style: GoogleFonts.lato(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B8E23))),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  void _editDefaultCategory(Activity activity) {
    // Abre o formulário com os dados da categoria padrão
    showDialog(
      context: context,
      builder: (_) => _CategoryFormDialog(
        initialData: {
          'group': activity.group,
          'icon': activity.icon,
          'practices': activity.practices
              .map((p) => {
                    'name': p.name,
                    'energy': p.energy,
                    'flow': p.flow,
                    'organ': p.organ,
                  })
              .toList(),
        },
        onSave: (updated) async {
          // Salva como customizada (substitui a padrão)
          final existingIndex =
              _customData.indexWhere((c) => c['group'] == activity.group);
          if (existingIndex >= 0) {
            await CustomActivitiesManager.updateCustomActivity(
                existingIndex, updated);
          } else {
            await CustomActivitiesManager.addCustomActivity(updated);
          }
          await _loadData();
          widget.onActivitiesChanged();
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFFE8F0D5),
            Color(0xFFF5F9E9),
            Color(0xFFD4E8C2)
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.5))),
      child: Row(children: [
        GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: const Color(0xFF6B8E23).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF6B8E23), size: 20))),
        const SizedBox(width: 10),
        Text('Categorias',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A5D23))),
        const Spacer(),
        GestureDetector(
          onTap: () async {
            await CustomActivitiesManager.resetToDefault();
            await _loadData();
            widget.onActivitiesChanged();
          },
          child: Text('Reset',
              style: GoogleFonts.lato(
                  fontSize: 11,
                  color: Colors.red[400],
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ========== DIÁLOGO: NOVA/EDITAR CATEGORIA ==========
class _CategoryFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Activity) onSave;
  const _CategoryFormDialog({this.initialData, required this.onSave});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _nameCtrl = TextEditingController();
  final _iconCtrl = TextEditingController(text: '✨');
  final _practiceCtrl = TextEditingController();
  String _energy = 'Ativa', _flow = 'Médio', _organ = 'Mente';
  List<Practice> _practices = [];

  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.initialData!['group'] ?? '';
      _iconCtrl.text = widget.initialData!['icon'] ?? '✨';
      final list = widget.initialData!['practices'] as List? ?? [];
      _practices = list
          .map((p) => Practice(
              name: p['name'] ?? '',
              energy: p['energy'] ?? 'Ativa',
              flow: p['flow'] ?? 'Médio',
              organ: p['organ'] ?? 'Mente'))
          .toList();
    }
  }

  void _add() {
    if (_practiceCtrl.text.trim().isEmpty) return;
    setState(() {
      _practices.add(Practice(
          name: _practiceCtrl.text.trim(),
          energy: _energy,
          flow: _flow,
          organ: _organ));
      _practiceCtrl.clear();
    });
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty || _practices.isEmpty) return;
    widget.onSave(Activity(
        group: _nameCtrl.text.trim(),
        icon: _iconCtrl.text.trim().isEmpty ? '✨' : _iconCtrl.text.trim(),
        practices: _practices));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _iconCtrl.dispose();
    _practiceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(_isEditing ? '✏️' : '✨',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          _isEditing ? 'Editar Categoria' : 'Nova Categoria',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 18, fontWeight: FontWeight.bold))),
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
                _label('Nome'),
                _field(_nameCtrl, 'Ex: Yoga, Jardinagem...'),
                const SizedBox(height: 10),
                _label('Ícone'),
                _field(_iconCtrl, '✨'),
                const SizedBox(height: 16),
                Text('Adicionar Prática',
                    style: GoogleFonts.lato(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _field(_practiceCtrl, 'Nome da prática')),
                  const SizedBox(width: 8),
                  GestureDetector(
                      onTap: _add,
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: const Color(0xFF6B8E23),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 20)))
                ]),
                const SizedBox(height: 8),
                _segmented(['Ativa', 'Passiva'], _energy,
                    (v) => setState(() => _energy = v)),
                const SizedBox(height: 6),
                _segmented([
                  'Fácil',
                  'Fácil – Médio',
                  'Médio',
                  'Médio – Difícil',
                  'Difícil'
                ], _flow, (v) => setState(() => _flow = v)),
                const SizedBox(height: 6),
                _segmented(['Mente', 'Corpo', 'Corpo/Mente'], _organ,
                    (v) => setState(() => _organ = v)),
                if (_practices.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ..._practices.asMap().entries.map((e) => Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[200]!)),
                        child: Row(children: [
                          Expanded(
                              child: Text(
                                  '${e.value.name} (${e.value.energy}·${e.value.flow}·${e.value.organ})',
                                  style: GoogleFonts.lato(fontSize: 11))),
                          GestureDetector(
                              onTap: () =>
                                  setState(() => _practices.removeAt(e.key)),
                              child: const Icon(Icons.close_rounded,
                                  size: 14, color: Colors.red)),
                        ]),
                      )),
                ],
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: (_nameCtrl.text.isNotEmpty && _practices.isNotEmpty)
                      ? _save
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0xFF6B8E23).withOpacity(
                              (_nameCtrl.text.isNotEmpty &&
                                      _practices.isNotEmpty)
                                  ? 1.0
                                  : 0.4),
                          const Color(0xFF8B6914).withOpacity(
                              (_nameCtrl.text.isNotEmpty &&
                                      _practices.isNotEmpty)
                                  ? 1.0
                                  : 0.4)
                        ]),
                        borderRadius: BorderRadius.circular(15)),
                    child: Text(_isEditing ? 'SALVAR' : 'CRIAR CATEGORIA',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(t,
          style: GoogleFonts.lato(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600])));
  Widget _field(TextEditingController c, String h) => Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!)),
      child: TextField(
          controller: c,
          style: GoogleFonts.lato(fontSize: 13),
          decoration: InputDecoration(
              hintText: h,
              hintStyle:
                  GoogleFonts.lato(fontSize: 12, color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10))));

  Widget _segmented(List<String> opts, String cur, Function(String) onCh) =>
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: opts.map((o) {
              final sel = cur == o;
              return GestureDetector(
                  onTap: () => onCh(o),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                          color: sel
                              ? const Color(0xFF6B8E23)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(o,
                          style: GoogleFonts.lato(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : Colors.grey[600]))));
            }).toList())),
      );
}

// ========== DIÁLOGO: ADICIONAR PRÁTICA ==========
class _PracticeFormDialog extends StatefulWidget {
  final String categoryName;
  final Function(Practice) onSave;
  const _PracticeFormDialog({required this.categoryName, required this.onSave});

  @override
  State<_PracticeFormDialog> createState() => _PracticeFormDialogState();
}

class _PracticeFormDialogState extends State<_PracticeFormDialog> {
  final _ctrl = TextEditingController();
  String _energy = 'Ativa', _flow = 'Médio', _organ = 'Mente';

  void _save() {
    if (_ctrl.text.trim().isEmpty) return;
    widget.onSave(Practice(
        name: _ctrl.text.trim(), energy: _energy, flow: _flow, organ: _organ));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nova Prática em "${widget.categoryName}"',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!)),
                  child: TextField(
                      controller: _ctrl,
                      style: GoogleFonts.lato(fontSize: 13),
                      decoration: InputDecoration(
                          hintText: 'Nome da prática',
                          hintStyle: GoogleFonts.lato(
                              fontSize: 12, color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10)))),
              const SizedBox(height: 12),
              Text('Energia',
                  style: GoogleFonts.lato(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[600])),
              _seg(['Ativa', 'Passiva'], _energy,
                  (v) => setState(() => _energy = v)),
              const SizedBox(height: 8),
              Text('Flow',
                  style: GoogleFonts.lato(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[600])),
              _seg([
                'Fácil',
                'Fácil – Médio',
                'Médio',
                'Médio – Difícil',
                'Difícil'
              ], _flow, (v) => setState(() => _flow = v)),
              const SizedBox(height: 8),
              Text('Foco',
                  style: GoogleFonts.lato(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[600])),
              _seg(['Mente', 'Corpo', 'Corpo/Mente'], _organ,
                  (v) => setState(() => _organ = v)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _ctrl.text.isNotEmpty ? _save : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        const Color(0xFF6B8E23)
                            .withOpacity(_ctrl.text.isNotEmpty ? 1.0 : 0.4),
                        const Color(0xFF8B6914)
                            .withOpacity(_ctrl.text.isNotEmpty ? 1.0 : 0.4)
                      ]),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('ADICIONAR PRÁTICA',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ]),
      ),
    );
  }

  Widget _seg(List<String> opts, String cur, Function(String) onCh) =>
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: opts.map((o) {
              final sel = cur == o;
              return GestureDetector(
                  onTap: () => onCh(o),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                          color: sel
                              ? const Color(0xFF6B8E23)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(o,
                          style: GoogleFonts.lato(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : Colors.grey[600]))));
            }).toList())),
      );
}
