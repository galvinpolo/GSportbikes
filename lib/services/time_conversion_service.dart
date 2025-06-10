import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timezone_model.dart';

class TimeConversionService {
  static const String _historyKey = 'time_conversion_history';
  static const int _maxHistoryItems = 50;

  // Convert time between timezones
  static DateTime convertTime({
    required DateTime time,
    required TimeZoneInfo fromTimeZone,
    required TimeZoneInfo toTimeZone,
  }) {
    final convertedTime = fromTimeZone.convertTo(time, toTimeZone);

    // Save to history
    _saveToHistory(TimeConversionHistory(
      originalTime: time,
      fromTimeZone: fromTimeZone,
      toTimeZone: toTimeZone,
      convertedTime: convertedTime,
      timestamp: DateTime.now(),
    ));

    return convertedTime;
  }

  // Get current time in all supported timezones
  static Map<String, DateTime> getCurrentTimeInAllZones() {
    final now = DateTime.now().toUtc();
    final timeZones = TimeZoneInfo.getSupportedTimeZones();

    Map<String, DateTime> times = {};
    for (final tz in timeZones) {
      times[tz.code] = tz.convertFromUTC(now);
    }

    return times;
  }

  // Get world clock - current time in all timezones
  static List<Map<String, dynamic>> getWorldClock() {
    final currentTimes = getCurrentTimeInAllZones();
    final timeZones = TimeZoneInfo.getSupportedTimeZones();

    return timeZones.map((tz) {
      return {
        'timeZone': tz,
        'currentTime': currentTimes[tz.code]!,
        'formattedTime': formatTime(currentTimes[tz.code]!),
        'formattedDate': formatDate(currentTimes[tz.code]!),
      };
    }).toList();
  }

  // Format time in HH:mm:ss format
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  // Format date in dd/MM/yyyy format
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // Format full date and time
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  // Get day name
  static String getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
  }

  // Get month name
  static String getMonthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[date.month - 1];
  }

  // Get formatted date with day and month names
  static String getFormattedDateWithNames(DateTime date) {
    return '${getDayName(date)}, ${date.day} ${getMonthName(date)} ${date.year}';
  }

  // Save conversion to history
  static Future<void> _saveToHistory(TimeConversionHistory conversion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      // Add new conversion to the beginning
      historyJson.insert(0, jsonEncode(conversion.toJson()));

      // Keep only the latest items
      if (historyJson.length > _maxHistoryItems) {
        historyJson.removeRange(_maxHistoryItems, historyJson.length);
      }

      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      print('Error saving time conversion history: $e');
    }
  }

  // Get conversion history
  static Future<List<TimeConversionHistory>> getConversionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      return historyJson.map((json) {
        return TimeConversionHistory.fromJson(jsonDecode(json));
      }).toList();
    } catch (e) {
      print('Error loading time conversion history: $e');
      return [];
    }
  }

  // Clear conversion history
  static Future<void> clearConversionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing time conversion history: $e');
    }
  }

  // Get time difference between two timezones
  static String getTimeDifference(TimeZoneInfo from, TimeZoneInfo to) {
    final diff = to.offsetHours - from.offsetHours;
    if (diff == 0) {
      return 'Same time';
    } else if (diff > 0) {
      return '+${diff} hours';
    } else {
      return '${diff} hours';
    }
  }

  // Check if it's daytime (6 AM - 6 PM)
  static bool isDaytime(DateTime time) {
    return time.hour >= 6 && time.hour < 18;
  }

  // Get time period (Morning, Afternoon, Evening, Night)
  static String getTimePeriod(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }

  // Get appropriate icon for time period
  static String getTimePeriodIcon(DateTime time) {
    final period = getTimePeriod(time);
    switch (period) {
      case 'Morning':
        return '🌅';
      case 'Afternoon':
        return '☀️';
      case 'Evening':
        return '🌆';
      case 'Night':
        return '🌙';
      default:
        return '🕐';
    }
  }
}
