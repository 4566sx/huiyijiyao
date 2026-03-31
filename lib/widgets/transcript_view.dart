import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TranscriptView extends StatelessWidget {
  final String transcript;
  final ScrollController? controller;

  const TranscriptView({
    super.key,
    required this.transcript,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.text_snippet,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Transcript',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (transcript.isEmpty)
              const Text(
                'No transcript yet. Start recording to see real-time transcription...',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Text(
                transcript,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
          ],
        ),
      ),
    );
  }
}
