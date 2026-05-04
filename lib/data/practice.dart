class Practice {
  final String name;
  final String energy;
  final String flow;
  final String organ;

  const Practice({
    required this.name,
    required this.energy,
    required this.flow,
    required this.organ,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'energy': energy,
        'flow': flow,
        'organ': organ,
      };

  factory Practice.fromJson(Map<String, dynamic> json) => Practice(
        name: json['name'] as String,
        energy: json['energy'] as String,
        flow: json['flow'] as String,
        organ: json['organ'] as String,
      );
}
