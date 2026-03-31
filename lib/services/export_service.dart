import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/meeting.dart';
import 'package:intl/intl.dart';

class ExportService {
  Future<String?> exportToWord(Meeting meeting) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(meeting.startTime);
      final fileName = 'meeting_$timestamp.txt';
      final filePath = '${dir.path}/$fileName';

      final duration = meeting.endTime != null
          ? _calculateDuration(meeting.startTime, meeting.endTime!)
          : 'N/A';

      final content = '''
${meeting.title}
${'=' * 50}
Date: ${DateFormat('yyyy-MM-dd HH:mm').format(meeting.startTime)}
Duration: $duration

TRANSCRIPT
${'-' * 30}
${meeting.transcript.isEmpty ? 'No transcript available.' : meeting.transcript}

MEETING MINUTES
${'-' * 30}
${meeting.minutes.isEmpty ? 'No minutes generated.' : meeting.minutes}
''';

      final file = File(filePath);
      await file.writeAsString(content);
      return filePath;
    } catch (e) {
      print('Export error: $e');
      return null;
    }
  }

  String _calculateDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes != 1 ? 's' : ''}';
    }
    return '$minutes minute${minutes != 1 ? 's' : ''}';
  }
}
