import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/practice.dart';

class PracticeFormSheet extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final Function(Practice) onSave;
  const PracticeFormSheet({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.onSave,
  });

  @override
  State<PracticeFormSheet> createState() => _PracticeFormSheetState();
}

class _PracticeFormSheetState extends State<PracticeFormSheet> {
  final _ctrl = TextEditingController();
  String _energy = 'Ativa', _flow = 'Médio', _organ = 'Mente';

  bool get _canSave => _ctrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
  }

  void _save() {
    if (!_canSave) return;
    widget.onSave(Practice(name: _ctrl.text.trim(), energy: _energy, flow: _flow, organ: _organ));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFF6B8E23).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(widget.categoryIcon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Nova Prática', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('em ${widget.categoryName}',
                      style: GoogleFonts.lato(fontSize: 13, color: const Color(0xFF6B8E23), fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
            const SizedBox(height: 24),
            _label('Nome da prática'),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[200]!)),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                style: GoogleFonts.lato(fontSize: 15),
                decoration: InputDecoration(
                    hintText: 'Ex: Meditação guiada, Leitura...',
                    hintStyle: GoogleFonts.lato(fontSize: 14, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
              ),
            ),
            const SizedBox(height: 22),
            _label('⚡ Energia'),
            _subLabel('Qual tipo de energia essa prática mobiliza?'),
            const SizedBox(height: 8),
            _chips(['Ativa', 'Passiva'], _energy, (v) => setState(() => _energy = v)),
            const SizedBox(height: 20),
            _label('🌊 Dificuldade'),
            _subLabel('Qual o nível de esforço necessário?'),
            const SizedBox(height: 8),
            _chips(['Fácil', 'Fácil – Médio', 'Médio', 'Médio – Difícil', 'Difícil'], _flow,
                (v) => setState(() => _flow = v)),
            const SizedBox(height: 20),
            _label('🎯 Foco'),
            _subLabel('Qual dimensão essa prática desenvolve?'),
            const SizedBox(height: 8),
            _chips(['Mente', 'Corpo', 'Corpo/Mente', 'Espírito'], _organ, (v) => setState(() => _organ = v)),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _canSave ? _save : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      const Color(0xFF6B8E23).withOpacity(_canSave ? 1.0 : 0.35),
                      const Color(0xFF8B6914).withOpacity(_canSave ? 1.0 : 0.35),
                    ]),
                    borderRadius: BorderRadius.circular(16)),
                child: Text('ADICIONAR PRÁTICA',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(t, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF2D3436))),
      );

  Widget _subLabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Text(t, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic)),
      );

  Widget _chips(List<String> opts, String cur, Function(String) onCh) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: opts.map((o) {
          final sel = cur == o;
          return GestureDetector(
            onTap: () => onCh(o),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF6B8E23) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? const Color(0xFF6B8E23) : Colors.grey[300]!, width: sel ? 2 : 1),
              ),
              child: Text(o,
                  style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: sel ? Colors.white : Colors.grey[700])),
            ),
          );
        }).toList(),
      );
}
