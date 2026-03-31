import 'dart:io';
import 'package:docx_creator/docx_creator.dart';
import 'package:path_provider/path_provider.dart';
import '../models/meeting.dart';
import 'package:intl/intl.dart';

class ExportService {
  Future<String?> exportToWord(Meeting meeting) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'meeting_${DateFormat('yyyyMMdd_HHmmss').format(meeting.startTime)}.docx';
      final filePath = '${dir.path}/$fileName';

      final creator = DocxCreator();
      creator.addParagraph(
        meeting.title,
        alignment: AlignmentType.center,
        fontSize: 18,
        bold: true,
        spacingAfter: 200,
      );

      creator.addParagraph(
        'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(meeting.startTime)}',
        fontSize: 12,
        italic: true,
        spacingAfter: 100,
      );

      if (meeting.endTime != null) {
        creator.addParagraph(
          'Duration: ${_calculateDuration(meeting.startTime, meeting.endTime!)}',
          fontSize: 12,
          italic: true,
          spacingAfter: 300,
        );
      }

      creator.addParagraph(
        'TRANSCRIPT',
        fontSize: 14,
        bold: true,
        spacingAfter: 100,
      );

      creator.addParagraph(
        meeting.transcript.isEmpty ? 'No transcript available.' : meeting.transcript,
        fontSize: 11,
        spacingAfter: 300,
      );

      creator.addParagraph(
        'MEETING MINUTES',
        fontSize: 14,
        bold: true,
        spacingAfter: 100,
      );

      creator.addParagraph(
        meeting.minutes.isEmpty ? 'No minutes generated.' : meeting.minutes,
        fontSize: 11,
        spacingAfter: 200,
      );

      await creator.save(filePath);
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
