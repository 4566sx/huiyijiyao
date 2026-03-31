import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:docx_template/docx_template.dart';
import '../models/meeting.dart';
import 'package:intl/intl.dart';

class ExportService {
  Future<String?> exportToWord(Meeting meeting) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'meeting_${DateFormat('yyyyMMdd_HHmmss').format(meeting.startTime)}.docx';
      final filePath = '${dir.path}/$fileName';

      final duration = meeting.endTime != null
          ? _calculateDuration(meeting.startTime, meeting.endTime!)
          : 'N/A';

      final doc = DocTemplate('');
      final data = {
        'title': meeting.title,
        'date': DateFormat('yyyy-MM-dd HH:mm').format(meeting.startTime),
        'duration': duration,
        'transcript': meeting.transcript.isEmpty ? 'No transcript available.' : meeting.transcript,
        'minutes': meeting.minutes.isEmpty ? 'No minutes generated.' : meeting.minutes,
      };

      final docx = DocxGenerator(doc);
      final bytes = await docx.generate(data);
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      print('Export error: $e');
      return _exportFallback(meeting);
    }
  }

  Future<String?> _exportFallback(Meeting meeting) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'meeting_${DateFormat('yyyyMMdd_HHmmss').format(meeting.startTime)}.txt';
      final filePath = '${dir.path}/$fileName';

      final content = '''
${meeting.title}
Date: ${DateFormat('yyyy-MM-dd HH:mm').format(meeting.startTime)}
${meeting.endTime != null ? 'Duration: ${_calculateDuration(meeting.startTime, meeting.endTime!)}' : ''}

=== TRANSCRIPT ===
${meeting.transcript.isEmpty ? 'No transcript available.' : meeting.transcript}

=== MEETING MINUTES ===
${meeting.minutes.isEmpty ? 'No minutes generated.' : meeting.minutes}
''';

      final file = File(filePath);
      await file.writeAsString(content);
      return filePath;
    } catch (e) {
      print('Fallback export error: $e');
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
