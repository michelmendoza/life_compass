import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/activities.dart';
import '../../data/practice.dart';
import '../../l10n/app_localizations.dart';

class CategoryFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Activity) onSave;
  const CategoryFormDialog({super.key, this.initialData, required this.onSave});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _nameCtrl = TextEditingController();
  final _iconCtrl = TextEditingController(text: '✨');
  List<Practice> _practices = [];

  bool get _isEditing => widget.initialData != null;
  bool get _canSave => _nameCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
    if (_isEditing) {
      _nameCtrl.text = widget.initialData!['group'] ?? '';
      _iconCtrl.text = widget.initialData!['icon'] ?? '✨';
      final list = widget.initialData!['practices'] as List? ?? [];
      _practices = list
          .map((p) => Practice(
              name: p['name'] ?? '',
              energy: p['energy'] ?? 'Ativa',
              flow: p['flow'] ?? 'Médio',
              organ: p['organ'] ?? 'Mente',
              idealMinutes: p['idealMinutes'] ?? 60))
          .toList();
    }
  }

  void _save() {
    if (!_canSave) return;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(24)),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header — fixo
                Row(children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(_isEditing ? '✏️' : '✨',
                          style: const TextStyle(fontSize: 20))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                            _isEditing
                                ? AppLocalizations.of(context).editCategoryTitle
                                : AppLocalizations.of(context).newCategoryTitle,
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        if (!_isEditing)
                          Text(AppLocalizations.of(context).practicesAddedLater,
                              style: GoogleFonts.lato(
                                  fontSize: 11,
                                  color: Colors.grey[400],
                                  fontStyle: FontStyle.italic)),
                      ])),
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.close_rounded,
                              size: 18, color: Colors.grey))),
                ]),
                const SizedBox(height: 20),

                // Conteúdo scrollável
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _label(AppLocalizations.of(context).iconLabel),
                            SizedBox(
                              width: 64,
                              child: _field(_iconCtrl, '✨', textAlign: TextAlign.center),
                            ),
                          ]),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                            _label(AppLocalizations.of(context).categoryNameLabel),
                            _field(_nameCtrl, AppLocalizations.of(context).categoryNameHint),
                          ])),
                        ]),
                        if (_isEditing) ...[
                          const SizedBox(height: 20),
                          Row(children: [
                            Text(AppLocalizations.of(context).practicesFormLabel,
                                style: GoogleFonts.lato(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[600])),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF6B8E23).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text('${_practices.length}',
                                  style: GoogleFonts.lato(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF6B8E23))),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          if (_practices.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.amber.withOpacity(0.3))),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.info_outline_rounded, size: 14, color: Colors.amber[700]),
                                    const SizedBox(width: 6),
                                    Text(AppLocalizations.of(context).noPracticesYet,
                                        style: GoogleFonts.lato(
                                            fontSize: 12,
                                            color: Colors.amber[800],
                                            fontStyle: FontStyle.italic)),
                                  ]),
                            )
                          else
                            ..._practices.asMap().entries.map((e) => Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[200]!)),
                                  child: Row(children: [
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                          Text(e.value.name,
                                              style: GoogleFonts.lato(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF2D3436))),
                                          const SizedBox(height: 2),
                                          Text('${e.value.energy} · ${e.value.flow} · ${e.value.organ} · ${e.value.idealMinutes}min',
                                              style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[500])),
                                        ])),
                                    GestureDetector(
                                        onTap: () => setState(() => _practices.removeAt(e.key)),
                                        child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(8)),
                                            child: const Icon(Icons.delete_outline_rounded,
                                                size: 16, color: Colors.red))),
                                  ]),
                                )),
                        ],
                      ],
                    ),
                  ),
                ),

                // Botão salvar — fixo
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _canSave ? _save : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0xFF6B8E23).withOpacity(_canSave ? 1.0 : 0.35),
                          const Color(0xFF8B6914).withOpacity(_canSave ? 1.0 : 0.35),
                        ]),
                        borderRadius: BorderRadius.circular(16)),
                    child: Text(_isEditing
                        ? AppLocalizations.of(context).saveBtn
                        : AppLocalizations.of(context).createCategoryBtn,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Colors.white)),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t,
          style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[600])));

  Widget _field(TextEditingController c, String h, {TextAlign textAlign = TextAlign.start}) =>
      Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!)),
          child: TextField(
              controller: c,
              textAlign: textAlign,
              style: GoogleFonts.lato(fontSize: 14),
              decoration: InputDecoration(
                  hintText: h,
                  hintStyle: GoogleFonts.lato(fontSize: 13, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))));
}
