import 'package:timezone/data/latest.dart' as tz;
import '../models/simple_timezone_model.dart';

class SimpleTimeConversionService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!_initialized) {
      tz.initializeTimeZones();
      _initialized = true;
    }
  }

  static DateTime convertTime({
    required DateTime time,
    required SimpleTimeZone fromTimeZone,
    required SimpleTimeZone toTimeZone,
  }) {
    // Calculate the difference in hours between timezones
    final offsetDifference = toTimeZone.offsetHours - fromTimeZone.offsetHours;

    // Convert the time
    return time.add(Duration(hours: offsetDifference));
  }

  static String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String formatDate(DateTime time) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${time.day} ${months[time.month - 1]} ${time.year}';
  }

  static String formatDateTime(DateTime time) {
    return '${formatDate(time)} ${formatTime(time)}';
  }

  static String getTimeDifference(SimpleTimeZone from, SimpleTimeZone to) {
    final diff = to.offsetHours - from.offsetHours;
    if (diff == 0) return 'Same time';
    if (diff > 0) return '+$diff hours';
    return '$diff hours';
  }

  static Map<String, DateTime> getCurrentTimeInAllZones() {
    final now = DateTime.now();
    final zones = SimpleTimeZone.getSupportedTimeZones();
    final Map<String, DateTime> times = {};

    for (final zone in zones) {
      // Assume 'now' is in WIB (UTC+7) and convert to other zones
      final wibOffset = 7;
      final utcTime = now.subtract(Duration(hours: wibOffset));
      final zoneTime = utcTime.add(Duration(hours: zone.offsetHours));
      times[zone.code] = zoneTime;
    }

    return times;
  }

  static String getTimeFlag(String timeZoneCode) {
    switch (timeZoneCode) {
      case 'WIB':
        return '🇮🇩';
      case 'WITA':
        return '🇮🇩';
      case 'WIT':
        return '🇮🇩';
      case 'GMT':
        return '🇬🇧';
      default:
        return '🌍';
    }
  }

  static String getTimePeriod(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 21) return 'Evening';
    return 'Night';
  }

  static bool isDaytime(DateTime time) {
    final hour = time.hour;
    return hour >= 6 && hour < 18;
  }
}
