import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;
  final double size;

  const RecordButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
          boxShadow: [
            if (isRecording)
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
          ],
        ),
        child: Icon(
          isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}
