class Practice {
  final String name;
  final String energy;
  final String flow;
  final String organ;
  final int idealMinutes;
  final String? reminder;

  const Practice({
    required this.name,
    required this.energy,
    required this.flow,
    required this.organ,
    required this.idealMinutes,
    this.reminder,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'energy': energy,
        'flow': flow,
        'organ': organ,
        'idealMinutes': idealMinutes,
        if (reminder != null && reminder!.isNotEmpty) 'reminder': reminder,
      };

  factory Practice.fromJson(Map<String, dynamic> json) => Practice(
        name: json['name'] as String,
        energy: json['energy'] as String,
        flow: json['flow'] as String,
        organ: json['organ'] as String,
        idealMinutes: json['idealMinutes'] as int? ?? 60,
        reminder: json['reminder'] as String?,
      );
}
