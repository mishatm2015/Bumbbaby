/// A prenatal / medical appointment saved by the user.
class Appointment {
  const Appointment({
    required this.id,
    required this.title,
    required this.place,
    required this.dateTime,
    this.dotColorValue = 0xFF9B7ED9,
  });

  final String id;
  final String title;
  final String place;
  final DateTime dateTime;
  final int dotColorValue;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'place': place,
        'dateTime': dateTime.toIso8601String(),
        'dotColorValue': dotColorValue,
      };

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      place: map['place'] as String? ?? '',
      dateTime:
          DateTime.tryParse(map['dateTime'] as String? ?? '') ?? DateTime.now(),
      dotColorValue: (map['dotColorValue'] as num?)?.toInt() ?? 0xFF9B7ED9,
    );
  }
}
