import 'package:hive_flutter/hive_flutter.dart';
import 'activities.dart';
import 'practice.dart';

class CustomActivitiesManager {
  static const String _boxName = 'custom_activities';

  static Future<List<Activity>> loadActivities() async {
    final box = await Hive.openBox(_boxName);
    final customData = box.get('categories', defaultValue: []);
    final deletedDefaults =
        List<String>.from(box.get('deletedDefaults', defaultValue: []));

    // Começa com as categorias padrão, exceto as excluídas pelo usuário
    final List<Activity> result = Activity.activities
        .where((a) => !deletedDefaults.contains(a.group))
        .toList();

    // Guarda os nomes das categorias customizadas
    final Set<String> customNames = {};

    // Processa as customizadas
    for (final data in customData) {
      if (data is Map) {
        final map = _convertMap(data);
        final practicesJson = map['practices'] as List? ?? [];
        final practices = practicesJson.map((p) => _parsePractice(p)).toList();

        final groupName = map['group']?.toString() ?? '';
        if (groupName.isNotEmpty) {
          customNames.add(groupName);

          final customActivity = Activity(
            group: groupName,
            icon: map['icon']?.toString() ?? '✨',
            practices: practices,
          );

          // Remove a padrão com o mesmo nome (se existir)
          result.removeWhere((a) => a.group == groupName);

          // Adiciona a customizada (mesmo que vazia)
          result.add(customActivity);
        }
      }
    }

    return result;
  }

  static Future<void> addCustomActivity(Activity activity) async {
    final box = await Hive.openBox(_boxName);
    final customData = List.from(box.get('categories', defaultValue: []));
    customData.add(activity.toJson());
    await box.put('categories', customData);
  }

  static Future<void> updateCustomActivity(int index, Activity activity) async {
    final box = await Hive.openBox(_boxName);
    final customData = List.from(box.get('categories', defaultValue: []));
    if (index >= 0 && index < customData.length) {
      customData[index] = activity.toJson();
      await box.put('categories', customData);
    }
  }

  static Future<void> removeCustomActivity(int index) async {
    final box = await Hive.openBox(_boxName);
    final customData = List.from(box.get('categories', defaultValue: []));
    if (index >= 0 && index < customData.length) {
      customData.removeAt(index);
      await box.put('categories', customData);
    }
  }

  /// Exclui uma categoria pelo nome, seja ela padrão, padrão editada ou
  /// totalmente customizada. Categorias padrão excluídas são marcadas
  /// (tombstone) para nunca mais reaparecer, igual a um dado customizado.
  static Future<void> deleteCategory(String groupName) async {
    final box = await Hive.openBox(_boxName);

    final customData = List.from(box.get('categories', defaultValue: []));
    customData.removeWhere((c) => _convertMap(c)['group'] == groupName);
    await box.put('categories', customData);

    final isDefault = Activity.activities.any((a) => a.group == groupName);
    if (isDefault) {
      final deletedDefaults =
          List<String>.from(box.get('deletedDefaults', defaultValue: []));
      if (!deletedDefaults.contains(groupName)) {
        deletedDefaults.add(groupName);
        await box.put('deletedDefaults', deletedDefaults);
      }
    }
  }

  static Future<List<Map<String, dynamic>>> getCustomActivities() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get('categories', defaultValue: []);
    final result = <Map<String, dynamic>>[];

    for (final item in raw) {
      if (item is Map) {
        final map = <String, dynamic>{};
        item.forEach((key, value) {
          map[key.toString()] = value;
        });
        result.add(map);
      }
    }

    for (final r in result) {
    }

    return result;
  }

  static Future<void> resetToDefault() async {
    final box = await Hive.openBox(_boxName);
    await box.put('categories', []);
    await box.put('deletedDefaults', []);
  }

  static Map<String, dynamic> _convertMap(Map data) {
    final map = <String, dynamic>{};
    data.forEach((key, value) {
      map[key.toString()] = value;
    });
    return map;
  }

  static Practice _parsePractice(dynamic p) {
    if (p is Map) {
      return Practice(
        name: p['name']?.toString() ?? '',
        energy: p['energy']?.toString() ?? 'Ativa',
        flow: p['flow']?.toString() ?? 'Médio',
        organ: p['organ']?.toString() ?? 'Mente',
        idealMinutes: int.tryParse(p['idealMinutes']?.toString() ?? '') ?? 60,
        reminder: p['reminder']?.toString(),
      );
    }
    return const Practice(
        name: '', energy: 'Ativa', flow: 'Médio', organ: 'Mente', idealMinutes: 60);
  }
}
