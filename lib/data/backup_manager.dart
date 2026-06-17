import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class ImportPreview {
  final int logs;
  final int categories;

  const ImportPreview({required this.logs, required this.categories});
}

class ImportResult {
  final int importedLogs;
  final int importedCategories;

  const ImportResult({
    required this.importedLogs,
    required this.importedCategories,
  });
}

class InvalidBackupFileException implements Exception {}

class BackupManager {
  static const _exportVersion = 1;

  static Future<Map<String, dynamic>> _buildExportData() async {
    final logsBox = await Hive.openBox('activity_logs');
    final customBox = await Hive.openBox('custom_activities');

    return {
      'exportVersion': _exportVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'activityLogs':
          logsBox.values.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      'customActivities': {
        'categories':
            List<dynamic>.from(customBox.get('categories', defaultValue: <dynamic>[])),
        'deletedDefaults': List<String>.from(
            customBox.get('deletedDefaults', defaultValue: <String>[])),
      },
    };
  }

  static Future<int> totalRecordsCount() async {
    final logsBox = await Hive.openBox('activity_logs');
    return logsBox.length;
  }

  /// Gera um arquivo JSON com todo o histórico e as personalizações do usuário.
  static Future<File> exportToFile() async {
    final data = await _buildExportData();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/rootflow_backup_$timestamp.json');
    return file.writeAsString(jsonStr);
  }

  static Future<Map<String, dynamic>> _readAndValidate(File file) async {
    final content = await file.readAsString();
    final dynamic decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic> ||
        (!decoded.containsKey('activityLogs') &&
            !decoded.containsKey('customActivities'))) {
      throw InvalidBackupFileException();
    }
    return decoded;
  }

  /// Lê um arquivo de backup e informa quantos itens seriam importados,
  /// sem persistir nada — usado para confirmar com o usuário antes de aplicar.
  static Future<ImportPreview> previewImport(File file) async {
    final data = await _readAndValidate(file);
    final logs = (data['activityLogs'] as List? ?? []).length;
    final categories =
        ((data['customActivities'] as Map?)?['categories'] as List? ?? []).length;
    return ImportPreview(logs: logs, categories: categories);
  }

  /// Importa logs e categorias customizadas, mesclando com os dados atuais.
  /// Nada existente é apagado: logs são indexados por id (sobrescreve se já
  /// existir o mesmo id) e categorias são mescladas por nome de grupo.
  static Future<ImportResult> importFromFile(File file) async {
    final data = await _readAndValidate(file);

    final logsBox = await Hive.openBox('activity_logs');
    final customBox = await Hive.openBox('custom_activities');

    int importedLogs = 0;
    for (final raw in (data['activityLogs'] as List? ?? [])) {
      final map = Map<String, dynamic>.from(raw as Map);
      final id = map['id']?.toString();
      if (id == null || id.isEmpty) continue;
      await logsBox.put(id, map);
      importedLogs++;
    }

    final customData = data['customActivities'] as Map? ?? {};

    int importedCategories = 0;
    final importedCats = List.from(customData['categories'] ?? []);
    if (importedCats.isNotEmpty) {
      final existing = List.from(customBox.get('categories', defaultValue: []));
      for (final cat in importedCats) {
        final catMap = Map<String, dynamic>.from(cat as Map);
        final groupName = catMap['group']?.toString();
        if (groupName == null || groupName.isEmpty) continue;
        existing.removeWhere(
            (c) => Map<String, dynamic>.from(c as Map)['group'] == groupName);
        existing.add(catMap);
        importedCategories++;
      }
      await customBox.put('categories', existing);
    }

    final importedDeleted = List<String>.from(customData['deletedDefaults'] ?? []);
    if (importedDeleted.isNotEmpty) {
      final existingDeleted =
          List<String>.from(customBox.get('deletedDefaults', defaultValue: []));
      for (final name in importedDeleted) {
        if (!existingDeleted.contains(name)) existingDeleted.add(name);
      }
      await customBox.put('deletedDefaults', existingDeleted);
    }

    return ImportResult(
        importedLogs: importedLogs, importedCategories: importedCategories);
  }

  /// Remove permanentemente todo o histórico e as personalizações do usuário.
  static Future<void> clearAllData() async {
    final logsBox = await Hive.openBox('activity_logs');
    final customBox = await Hive.openBox('custom_activities');
    await logsBox.clear();
    await customBox.clear();
  }
}
