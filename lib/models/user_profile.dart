import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    this.phone,
    this.dateOfBirth,
    this.age,
    this.height,
    this.prePregnancyWeight,
    this.bloodGroup,
    this.lmp,
    this.edd,
    this.pregnancyType = 'Single',
    this.previousPregnancies,
    this.doctorName,
    this.language = 'English',
    this.notificationPrefs,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String fullName;
  final String? phone;
  final String? dateOfBirth;
  final int? age;
  final String? height;
  final String? prePregnancyWeight;
  final String? bloodGroup;
  final String? lmp;
  final String? edd;
  final String pregnancyType;
  final int? previousPregnancies;
  final String? doctorName;
  final String language;
  final String? notificationPrefs;
  final DateTime? createdAt;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Gestational week from LMP (DD/MM/YYYY), clamped 1–42. Null if unparsable.
  int? get currentWeek {
    final lmpDate = _parseDdMmYyyy(lmp);
    if (lmpDate == null) return null;
    final days = DateTime.now().difference(lmpDate).inDays;
    if (days < 0) return 1;
    return (days ~/ 7 + 1).clamp(1, 42);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'height': height,
      'prePregnancyWeight': prePregnancyWeight,
      'bloodGroup': bloodGroup,
      'lmp': lmp,
      'edd': edd,
      'pregnancyType': pregnancyType,
      'previousPregnancies': previousPregnancies,
      'doctorName': doctorName,
      'language': language,
      'notificationPrefs': notificationPrefs,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String?,
      dateOfBirth: data['dateOfBirth'] as String?,
      age: (data['age'] as num?)?.toInt(),
      height: data['height'] as String?,
      prePregnancyWeight: data['prePregnancyWeight'] as String?,
      bloodGroup: data['bloodGroup'] as String?,
      lmp: data['lmp'] as String?,
      edd: data['edd'] as String?,
      pregnancyType: data['pregnancyType'] as String? ?? 'Single',
      previousPregnancies: (data['previousPregnancies'] as num?)?.toInt(),
      doctorName: data['doctorName'] as String?,
      language: data['language'] as String? ?? 'English',
      notificationPrefs: data['notificationPrefs'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static DateTime? _parseDdMmYyyy(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.trim().split(RegExp(r'[/-]'));
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }
}
