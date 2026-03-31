class Prompts {
  static const String meetingMinutesSystem = '''You are a professional meeting minutes assistant. Generate structured meeting minutes from transcripts.''';

  static String getMeetingMinutesPrompt(String transcript) {
    return '''You are a professional meeting minutes assistant. Based on the following meeting transcript, generate structured meeting minutes including:
1. Meeting Topic
2. Participants (extract from context)
3. Key Discussion Points
4. Decisions Made
5. Action Items (with assignee and deadline if mentioned)

Format the output clearly with headings and bullet points.

Transcript:
$transcript''';
  }
}
