class TimeZoneInfo {
  final String code;
  final String name;
  final String description;
  final int offsetHours;
  final String flag;

  TimeZoneInfo({
    required this.code,
    required this.name,
    required this.description,
    required this.offsetHours,
    required this.flag,
  });

  static List<TimeZoneInfo> getSupportedTimeZones() {
    return [
      TimeZoneInfo(
        code: 'WIB',
        name: 'Waktu Indonesia Barat',
        description: 'Jakarta, Medan, Palembang',
        offsetHours: 7,
        flag: '🇮🇩',
      ),
      TimeZoneInfo(
        code: 'WITA',
        name: 'Waktu Indonesia Tengah',
        description: 'Denpasar, Makassar, Balikpapan',
        offsetHours: 8,
        flag: '🇮🇩',
      ),
      TimeZoneInfo(
        code: 'WIT',
        name: 'Waktu Indonesia Timur',
        description: 'Jayapura, Ambon, Manokwari',
        offsetHours: 9,
        flag: '🇮🇩',
      ),
      TimeZoneInfo(
        code: 'GMT',
        name: 'Greenwich Mean Time',
        description: 'London, Dublin, Edinburgh',
        offsetHours: 0,
        flag: '🇬🇧',
      ),
    ];
  }

  static TimeZoneInfo fromCode(String code) {
    return getSupportedTimeZones().firstWhere(
      (tz) => tz.code == code,
      orElse: () => getSupportedTimeZones().first,
    );
  }

  DateTime convertFromUTC(DateTime utcTime) {
    return utcTime.add(Duration(hours: offsetHours));
  }

  DateTime convertToUTC(DateTime localTime) {
    return localTime.subtract(Duration(hours: offsetHours));
  }

  // Convert time from this timezone to another timezone
  DateTime convertTo(DateTime time, TimeZoneInfo targetTimeZone) {
    // First convert to UTC, then to target timezone
    final utcTime = convertToUTC(time);
    return targetTimeZone.convertFromUTC(utcTime);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeZoneInfo && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$code - $name';
}

class TimeConversionHistory {
  final DateTime originalTime;
  final TimeZoneInfo fromTimeZone;
  final TimeZoneInfo toTimeZone;
  final DateTime convertedTime;
  final DateTime timestamp;

  TimeConversionHistory({
    required this.originalTime,
    required this.fromTimeZone,
    required this.toTimeZone,
    required this.convertedTime,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'originalTime': originalTime.toIso8601String(),
      'fromTimeZone': fromTimeZone.code,
      'toTimeZone': toTimeZone.code,
      'convertedTime': convertedTime.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TimeConversionHistory.fromJson(Map<String, dynamic> json) {
    return TimeConversionHistory(
      originalTime: DateTime.parse(json['originalTime']),
      fromTimeZone: TimeZoneInfo.fromCode(json['fromTimeZone']),
      toTimeZone: TimeZoneInfo.fromCode(json['toTimeZone']),
      convertedTime: DateTime.parse(json['convertedTime']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
