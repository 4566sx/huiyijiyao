class Transcript {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isFinal;

  Transcript({
    required this.id,
    required this.text,
    required this.timestamp,
    this.isFinal = false,
  });

  Transcript copyWith({
    String? id,
    String? text,
    DateTime? timestamp,
    bool? isFinal,
  }) {
    return Transcript(
      id: id ?? this.id,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isFinal: isFinal ?? this.isFinal,
    );
  }
}
