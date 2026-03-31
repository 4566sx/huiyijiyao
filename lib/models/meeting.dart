class Meeting {
  final int? id;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String transcript;
  final String minutes;
  final String? audioPath;

  Meeting({
    this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.transcript = '',
    this.minutes = '',
    this.audioPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'transcript': transcript,
      'minutes': minutes,
      'audioPath': audioPath,
    };
  }

  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      id: map['id'],
      title: map['title'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      transcript: map['transcript'] ?? '',
      minutes: map['minutes'] ?? '',
      audioPath: map['audioPath'],
    );
  }

  Meeting copyWith({
    int? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? transcript,
    String? minutes,
    String? audioPath,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      transcript: transcript ?? this.transcript,
      minutes: minutes ?? this.minutes,
      audioPath: audioPath ?? this.audioPath,
    );
  }
}
