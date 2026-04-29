/// A Nusuk / Umrah entry permit document stored in Firestore.
class Permit {
  const Permit({
    required this.id,
    required this.permitNumber,
    required this.holderName,
    required this.permitType,
    required this.validFrom,
    required this.validTo,
    required this.status,
    this.passportNumber,
    this.nationality,
    this.qrData,
  });

  final String id;
  final String permitNumber;
  final String holderName;

  /// 'umrah' or 'hajj'
  final String permitType;

  final DateTime validFrom;
  final DateTime validTo;

  /// 'active' | 'pending' | 'expired'
  final String status;

  final String? passportNumber;
  final String? nationality;
  final String? qrData;

  factory Permit.fromMap(String id, Map<String, dynamic> data) {
    DateTime parseDate(dynamic v, String field) {
      if (v == null) throw FormatException('Permit $id: missing required date field "$field"');
      if (v is String) return DateTime.parse(v);
      // Firestore Timestamp
      try {
        return (v as dynamic).toDate() as DateTime;
      } catch (_) {
        throw FormatException('Permit $id: invalid date value for "$field"');
      }
    }

    return Permit(
      id: id,
      permitNumber: data['permitNumber'] as String? ?? '',
      holderName: data['holderName'] as String? ?? '',
      permitType: data['permitType'] as String? ?? 'umrah',
      validFrom: parseDate(data['validFrom'], 'validFrom'),
      validTo: parseDate(data['validTo'], 'validTo'),
      status: data['status'] as String? ?? 'pending',
      passportNumber: data['passportNumber'] as String?,
      nationality: data['nationality'] as String?,
      qrData: data['qrData'] as String?,
    );
  }
}
