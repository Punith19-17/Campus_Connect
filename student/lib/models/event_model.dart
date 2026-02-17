// lib/models/event_model.dart
import 'package:intl/intl.dart';

class Event {
  final int id;
  final String eventType;
  final String eventTitle;
  final String description;
  final DateTime date;        // date-only (local)
  final String startTime;     // stored as HH:mm:ss (string)
  final String endTime;       // stored as HH:mm:ss (string)
  final String location;
  final String organizedClub;
  final String? award;
  final int participants;

  Event({
    required this.id,
    required this.eventType,
    required this.eventTitle,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.organizedClub,
    this.award,
    this.participants = 0,
  });

  // Keep original date/time strings for editing / sending back to API
  String get originalDate => DateFormat('yyyy-MM-dd').format(date);
  String get originalTime => startTime;
  String get originalEndTime => endTime;

  // Nicely formatted date for display
  String get formattedDate {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  // Format time for display (HH:mm)
  String get formattedStartTime {
    return _formatTimeForDisplay(startTime);
  }

  String get formattedEndTime {
    return _formatTimeForDisplay(endTime);
  }

  String _formatTimeForDisplay(String timeStr) {
    // Accept formats like "HH:mm:ss" or "HH:mm" (ignore anything else)
    try {
      final parts = _extractTimeParts(timeStr);
      final hour = parts[0];
      final minute = parts[1];
      final displayHour = (hour == 0) ? 12 : (hour > 12 ? hour - 12 : hour);
      final period = hour >= 12 ? 'PM' : 'AM';
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$displayHour:$minuteStr $period';
    } catch (e) {
      return timeStr;
    }
  }

  // For list display like "Nov 20"
  String get displayDate {
    try {
      return '${_getMonthAbbreviation(date.month)} ${date.day}';
    } catch (e) {
      return 'N/A';
    }
  }

  // For list display time like "12:00 PM"
  String get displayTime {
    try {
      return formattedStartTime;
    } catch (e) {
      return startTime;
    }
  }

  // Construct a DateTime (local) for start (used for sorting/status)
  DateTime get fullDateTime {
    try {
      final timeParts = _extractTimeParts(startTime);
      return DateTime(date.year, date.month, date.day, timeParts[0], timeParts[1], timeParts[2]);
    } catch (e) {
      return DateTime(date.year, date.month, date.day);
    }
  }

  // Construct a DateTime (local) for end time
  DateTime get fullEndDateTime {
    try {
      final timeParts = _extractTimeParts(endTime);
      return DateTime(date.year, date.month, date.day, timeParts[0], timeParts[1], timeParts[2]);
    } catch (e) {
      return DateTime(date.year, date.month, date.day, 23, 59, 59);
    }
  }

  static String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  // -----------------------
  // Robust factory from JSON
  // -----------------------
  factory Event.fromJson(Map<String, dynamic> json) {
    DateTime parseEventDate(String? dateStr) {
      if (dateStr == null) return DateTime.now();

      try {
        // Extract yyyy-mm-dd using regex - this avoids timezone conversions
        final RegExp dateRe = RegExp(r'(\d{4}-\d{2}-\d{2})');
        final match = dateRe.firstMatch(dateStr);
        final datePart = match != null ? match.group(1)! : dateStr;

        final parts = datePart.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          // Create local date-only DateTime (no timezone shift)
          return DateTime(year, month, day);
        }
      } catch (e) {
        print('Error parsing event date: $e (input: $dateStr)');
      }
      return DateTime.now();
    }

    String extractTimeString(dynamic timeValue) {
      if (timeValue == null) return '00:00:00';
      final raw = timeValue.toString();

      // Try to find HH:mm:ss or HH:mm substring
      final RegExp timeRe = RegExp(r'(\d{1,2}:\d{2}(:\d{2})?)');
      final match = timeRe.firstMatch(raw);
      if (match != null) {
        final t = match.group(1)!;
        // Normalize to HH:mm:ss
        final parts = t.split(':');
        if (parts.length == 2) return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:00';
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:${parts[2].padLeft(2, '0')}';
      }
      // fallback
      return '00:00:00';
    }

    final eventDate = parseEventDate(json['date']?.toString() ?? json['event_date']?.toString());

    final startTimeStr = extractTimeString(json['time'] ?? json['start_time'] ?? json['start']);
    final endTimeStr = extractTimeString(json['end_time'] ?? json['end']);

    // Debug logging (leave these while testing)
    print('=== EVENT MODEL DEBUG ===');
    print('Raw date from API: ${json['date']}');
    print('Parsed event date (local): $eventDate');
    print('time raw: ${json['time']} -> startTimeStr: $startTimeStr');
    print('end_time raw: ${json['end_time']} -> endTimeStr: $endTimeStr');
    print('=========================');

    return Event(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id'] ?? 0}') ?? 0,
      eventType: json['event_type']?.toString() ?? 'N/A',
      eventTitle: json['event_title']?.toString() ?? 'No Title',
      description: json['description']?.toString() ?? 'No Description',
      date: eventDate,
      startTime: startTimeStr,
      endTime: endTimeStr,
      location: json['location']?.toString() ?? 'N/A',
      organizedClub: json['organized_club']?.toString() ?? 'N/A',
      award: json['award']?.toString(),
      participants: json['participants'] is int
          ? json['participants']
          : int.tryParse('${json['participants'] ?? 0}') ?? 0,
    );
  }

  // Convert to JSON for API calls (for updates)
  Map<String, dynamic> toJson() {
    return {
      'event_type': eventType,
      'event_title': eventTitle,
      'description': description,
      'date': originalDate,
      'time': startTime,
      'end_time': endTime,
      'location': location,
      'organized_club': organizedClub,
      'award': award,
    };
  }

  @override
  String toString() {
    return 'Event: $eventTitle ($formattedDate $formattedStartTime - $formattedEndTime at $location)';
  }

  // -----------------------
  // Private parser helpers
  // -----------------------
  /// Returns [hour, minute, second]
  static List<int> _extractTimeParts(String timeStr) {
    final RegExp timeRe = RegExp(r'(\d{1,2}):(\d{2})(?::(\d{2}))?');
    final match = timeRe.firstMatch(timeStr);
    if (match == null) throw FormatException('Invalid time format: $timeStr');
    final h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final s = match.group(3) != null ? int.parse(match.group(3)!) : 0;
    return [h, m, s];
  }
}
