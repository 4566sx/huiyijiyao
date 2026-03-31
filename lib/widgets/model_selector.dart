import 'package:flutter/material.dart';
import '../models/ai_config.dart';

class ModelSelector extends StatelessWidget {
  final AiModelType selectedType;
  final ValueChanged<AiModelType> onTypeChanged;

  const ModelSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Model',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AiModelType.values.map((type) {
              final isSelected = type == selectedType;
              return ChoiceChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (_) => onTypeChanged(type),
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
