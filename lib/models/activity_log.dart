import 'package:hive/hive.dart';

class ActivityLog extends HiveObject {
  final String id;
  final String group;
  final String example;
  final String energy;
  final String flow;
  final String organ;
  final int durationInSeconds;
  final DateTime timestamp;
  final int? consciousnessLevel;
  final String? difficultyFeedback;

  ActivityLog({
    required this.id,
    required this.group,
    required this.example,
    required this.energy,
    required this.flow,
    required this.organ,
    required Duration duration,
    required this.timestamp,
    this.consciousnessLevel = 0,
    this.difficultyFeedback = '',
  }) : durationInSeconds = duration.inSeconds;

  Duration get duration => Duration(seconds: durationInSeconds);

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    } else {
      return '${seconds}s';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group': group,
      'example': example,
      'energy': energy,
      'flow': flow,
      'organ': organ,
      'durationInSeconds': durationInSeconds,
      'timestamp': timestamp.toIso8601String(),
      'consciousnessLevel': consciousnessLevel, // ← ADICIONADO
      'difficultyFeedback': difficultyFeedback, // ← ADICIONADO
    };
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      group: json['group'] as String,
      example: json['example'] as String,
      energy: json['energy'] as String,
      flow: json['flow'] as String,
      organ: json['organ'] as String,
      duration: Duration(seconds: json['durationInSeconds'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
      consciousnessLevel:
          json['consciousnessLevel'] as int? ?? 0, // ← ADICIONADO
      difficultyFeedback:
          json['difficultyFeedback'] as String? ?? '', // ← ADICIONADO
    );
  }
}
