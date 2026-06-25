import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../data/backup_manager.dart';
import '../l10n/app_localizations.dart';
import '../locale_controller.dart';

class SettingsScreen extends StatefulWidget {
  final Box settingsBox;

  const SettingsScreen({super.key, required this.settingsBox});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = '${info.version}+${info.buildNumber}');
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.lato()),
        backgroundColor: isError ? Colors.red[400] : const Color(0xFF6B8E23),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ========== EXPORT ==========
  Future<void> _exportData() async {
    final l10n = AppLocalizations.of(context);
    final total = await BackupManager.totalRecordsCount();
    if (total == 0) {
      _showSnack(l10n.exportEmptyMessage);
      return;
    }
    final file = await BackupManager.exportToFile();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: l10n.exportShareSubject,
      ),
    );
    if (mounted) _showSnack(l10n.exportSuccessMessage);
  }

  // ========== IMPORT ==========
  Future<void> _importData() async {
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return;
    final file = File(path);

    ImportPreview preview;
    try {
      preview = await BackupManager.previewImport(file);
    } catch (_) {
      if (mounted) _showSnack(l10n.importErrorMessage, isError: true);
      return;
    }

    if (preview.logs == 0 && preview.categories == 0) {
      if (mounted) _showSnack(l10n.importEmptyFile, isError: true);
      return;
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF8F9FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.importConfirmTitle,
            style: GoogleFonts.playfairDisplay(
                fontSize: 17, fontWeight: FontWeight.bold)),
        content: Text(
          l10n.importConfirmMessage(preview.logs, preview.categories),
          style: GoogleFonts.lato(fontSize: 13, color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.importConfirmBtn,
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await BackupManager.importFromFile(file);
      if (mounted) _showSnack(l10n.importSuccessMessage);
    } catch (_) {
      if (mounted) _showSnack(l10n.importErrorMessage, isError: true);
    }
  }

  // ========== CLEAR DATA ==========
  Future<void> _clearData() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF8F9FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.clearDataConfirmTitle,
            style: GoogleFonts.playfairDisplay(
                fontSize: 17, fontWeight: FontWeight.bold)),
        content: Text(l10n.clearDataConfirmMessage,
            style: GoogleFonts.lato(fontSize: 13, color: Colors.grey[600])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          Container(
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [Colors.red[400]!, Colors.red[300]!]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.clearDataConfirmBtn,
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await BackupManager.clearAllData();
    if (mounted) _showSnack(l10n.clearDataSuccessMessage);
  }

  // ========== FAQ ==========
  void _showFaq() {
    final l10n = AppLocalizations.of(context);
    final items = [
      (l10n.faqQ1, l10n.faqA1),
      (l10n.faqQ2, l10n.faqA2),
      (l10n.faqQ3, l10n.faqA3),
      (l10n.faqQ4, l10n.faqA4),
      (l10n.faqQ5, l10n.faqA5),
      (l10n.faqQ6, l10n.faqA6),
      (l10n.faqQ7, l10n.faqA7),
      (l10n.faqQ8, l10n.faqA8),
      (l10n.faqQ9, l10n.faqA9),
      (l10n.faqQ10, l10n.faqA10),
      (l10n.faqQ11, l10n.faqA11),
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(l10n.settingsFaq,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (_, i) => ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      items[i].$1,
                      style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3436)),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          items[i].$2,
                          style: GoogleFonts.lato(
                              fontSize: 13, color: Colors.grey[600], height: 1.5),
                        ),
                      ),
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

  // ========== ABOUT ==========
  void _showAbout() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 28, 24, 32 + MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: Text('🌳', style: TextStyle(fontSize: 30))),
            ),
            const SizedBox(height: 16),
            Text('Root Flow',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A5D23))),
            const SizedBox(height: 4),
            if (_version.isNotEmpty)
              Text('${l10n.aboutVersionLabel} $_version',
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 16),
            Text(
              l10n.aboutAppDescription,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  fontSize: 13, color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.aboutPrivacyNote,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  // ========== LANGUAGE ==========
  void _showLanguagePicker() {
    final l10n = AppLocalizations.of(context);
    final current = appLocale.value;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.languagePickerTitle,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _languageOption(null, l10n.languageSystemDefault, current),
            _languageOption(const Locale('pt'), l10n.languagePortuguese, current),
            _languageOption(const Locale('en'), l10n.languageEnglish, current),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(Locale? locale, String label, Locale? current) {
    final selected = locale?.languageCode == current?.languageCode;
    return GestureDetector(
      onTap: () async {
        await setAppLocale(widget.settingsBox, locale);
        if (mounted) Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF6B8E23).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? const Color(0xFF6B8E23) : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? const Color(0xFF6B8E23)
                        : const Color(0xFF2D3436)),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF6B8E23), size: 20),
          ],
        ),
      ),
    );
  }

  // ========== SITE LINK ==========
  Future<void> _openSite() async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.parse('https://noardigital.com/rootflow/index.html');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) _showSnack(l10n.cantOpenLink, isError: true);
  }

  // ========== BUILD ==========
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              _buildAppBar(l10n),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionLabel(l10n.settingsSectionPreferences),
                    const SizedBox(height: 8),
                    _tile(
                      icon: Icons.language_rounded,
                      title: l10n.settingsLanguage,
                      subtitle: l10n.settingsLanguageDesc,
                      onTap: _showLanguagePicker,
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel(l10n.settingsSectionData),
                    const SizedBox(height: 8),
                    _tile(
                      icon: Icons.upload_file_rounded,
                      title: l10n.settingsExportData,
                      subtitle: l10n.settingsExportDataDesc,
                      onTap: _exportData,
                    ),
                    _tile(
                      icon: Icons.download_rounded,
                      title: l10n.settingsImportData,
                      subtitle: l10n.settingsImportDataDesc,
                      onTap: _importData,
                    ),
                    _tile(
                      icon: Icons.delete_forever_rounded,
                      title: l10n.settingsClearData,
                      subtitle: l10n.settingsClearDataDesc,
                      onTap: _clearData,
                      danger: true,
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel(l10n.settingsSectionSupport),
                    const SizedBox(height: 8),
                    _tile(
                      icon: Icons.help_outline_rounded,
                      title: l10n.settingsFaq,
                      onTap: _showFaq,
                    ),
                    _tile(
                      icon: Icons.info_outline_rounded,
                      title: l10n.settingsAbout,
                      onTap: _showAbout,
                    ),
                    _tile(
                      icon: Icons.language_rounded,
                      title: l10n.settingsVisitSite,
                      onTap: _openSite,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        _version.isEmpty ? 'Root Flow' : 'Root Flow • v$_version',
                        style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFFE8F0D5),
          Color(0xFFF5F9E9),
          Color(0xFFD4E8C2),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: const Color(0xFF6B8E23).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Color(0xFF6B8E23), size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settingsScreenTitle,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A5D23))),
                Text(l10n.settingsScreenSubtitle,
                    style: GoogleFonts.lato(
                        fontSize: 11,
                        color: const Color(0xFF6B8E23).withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text,
          style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.grey[600],
              letterSpacing: 1.5),
        ),
      );

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? Colors.red[400]! : const Color(0xFF6B8E23);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.3)),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: danger ? color : const Color(0xFF2D3436)),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[500]))
            : null,
        trailing: Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey[400]),
      ),
    );
  }
}
