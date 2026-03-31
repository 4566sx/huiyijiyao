import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/meeting.dart';
import 'package:intl/intl.dart';

class ExportService {
  Future<String?> exportToWord(Meeting meeting) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(meeting.startTime);
      final fileName = 'meeting_$timestamp.docx';
      final filePath = '${dir.path}/$fileName';

      final duration = meeting.endTime != null
          ? _calculateDuration(meeting.startTime, meeting.endTime!)
          : 'N/A';

      final content = _buildDocxContent(meeting, duration);

      final file = File(filePath);
      await file.writeAsBytes(content);
      return filePath;
    } catch (e) {
      print('Export error: $e');
      return _exportPlainText(meeting);
    }
  }

  Future<Uint8List> _buildDocxContent(Meeting meeting, String duration) async {
    final title = meeting.title;
    final date = DateFormat('yyyy-MM-dd HH:mm').format(meeting.startTime);
    final transcript = meeting.transcript.isEmpty ? 'No transcript available.' : meeting.transcript;
    final minutes = meeting.minutes.isEmpty ? 'No minutes generated.' : meeting.minutes;

    final xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<pkg:package xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage">
<pkg:part pkg:name="/_rels/.rels" pkg:contentType="application/vnd.openxmlformats-package.relationships+xml">
<pkg:xmlData><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships></pkg:xmlData></pkg:part>
<pkg:part pkg:name="/word/document.xml" pkg:contentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml">
<pkg:xmlData><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
<w:body>
<w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="36"/></w:rPr><w:t>${_escapeXml(title)}</w:t></w:r></w:p>
<w:p><w:r><w:rPr><w:i/><w:sz w:val="24"/></w:rPr><w:t>Date: ${_escapeXml(date)}</w:t></w:r></w:p>
<w:p><w:r><w:rPr><w:i/><w:sz w:val="24"/></w:rPr><w:t>Duration: ${_escapeXml(duration)}</w:t></w:r></w:p>
<w:p><w:r><w:rPr><w:b/><w:sz w:val="28"/></w:rPr><w:t>TRANSCRIPT</w:t></w:r></w:p>
<w:p><w:r><w:rPr><w:sz w:val="22"/></w:rPr><w:t>${_escapeXml(transcript)}</w:t></w:r></w:p>
<w:p><w:r><w:rPr><w:b/><w:sz w:val="28"/></w:rPr><w:t>MEETING MINUTES</w:t></w:r></w:p>
<w:p><w:r><w:rPr><w:sz w:val="22"/></w:rPr><w:t>${_escapeXml(minutes)}</w:t></w:r></w:p>
</w:body></w:document></pkg:xmlData></pkg:part>
</pkg:package>''';

    return xml.codeUnits;
  }

  Future<String?> _exportPlainText(Meeting meeting) async {
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
      print('Fallback export error: $e');
      return null;
    }
  }

  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
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
