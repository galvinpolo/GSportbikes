class SimpleTimeZone {
  final String name;
  final String code;
  final String location;
  final int offsetHours;

  const SimpleTimeZone({
    required this.name,
    required this.code,
    required this.location,
    required this.offsetHours,
  });

  static List<SimpleTimeZone> getSupportedTimeZones() {
    return [
      const SimpleTimeZone(
        name: 'Waktu Indonesia Barat',
        code: 'WIB',
        location: 'Jakarta',
        offsetHours: 7,
      ),
      const SimpleTimeZone(
        name: 'Waktu Indonesia Tengah',
        code: 'WITA',
        location: 'Makassar',
        offsetHours: 8,
      ),
      const SimpleTimeZone(
        name: 'Waktu Indonesia Timur',
        code: 'WIT',
        location: 'Jayapura',
        offsetHours: 9,
      ),
      const SimpleTimeZone(
        name: 'Greenwich Mean Time',
        code: 'GMT',
        location: 'London',
        offsetHours: 0,
      ),
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SimpleTimeZone && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$code - $name';
}
