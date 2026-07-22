/// A medication / supplement the user wants to track each day.
class Medicine {
  const Medicine({
    required this.id,
    required this.name,
    this.dose,
    this.time,
  });

  final String id;
  final String name;
  final String? dose;
  final String? time;

  Medicine copyWith({String? name, String? dose, String? time}) {
    return Medicine(
      id: id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'dose': dose,
        'time': time,
      };

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? '',
      dose: map['dose'] as String?,
      time: map['time'] as String?,
    );
  }
}
