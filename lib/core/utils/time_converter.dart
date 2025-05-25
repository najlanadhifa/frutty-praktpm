import 'package:intl/intl.dart';

class TimeConverter {
  static final Map<String, int> _timeOffsets = {
    'WIB': 7,   // UTC+7
    'WITA': 8,  // UTC+8
    'WIT': 9,   // UTC+9
    'London': 0 // UTC+0 (GMT)
  };

  /// Konversi waktu [dateTime] ke zona waktu tujuan [targetZone]
  static String convert(DateTime dateTime, String targetZone) {
    if (!_timeOffsets.containsKey(targetZone)) {
      throw Exception('Zona waktu tidak dikenal');
    }

    final offset = _timeOffsets[targetZone]!;
    final utcTime = dateTime.toUtc();
    final convertedTime = utcTime.add(Duration(hours: offset));
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return formatter.format(convertedTime);
  }
}
