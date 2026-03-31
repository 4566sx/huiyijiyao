import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/meeting.dart';
import '../providers/meeting_provider.dart';
import '../services/export_service.dart';
import '../services/api_service.dart';
import '../providers/config_provider.dart';

class MinutesScreen extends StatefulWidget {
  final Meeting meeting;

  const MinutesScreen({super.key, required this.meeting});

  @override
  State<MinutesScreen> createState() => _MinutesScreenState();
}

class _MinutesScreenState extends State<MinutesScreen> {
  final ExportService _exportService = ExportService();
  final ApiService _apiService = ApiService();
  late Meeting _meeting;
  bool _isGenerating = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _meeting = widget.meeting;
  }

  Future<void> _generateMinutes() async {
    if (_meeting.transcript.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transcript available')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    final configProvider = context.read<ConfigProvider>();
    final config = configProvider.currentConfig;

    if (config == null || config.apiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please configure AI settings first')),
        );
        setState(() {
          _isGenerating = false;
        });
      }
      return;
    }

    try {
      final minutes = await _apiService.generateMinutes(config, _meeting.transcript);

      final updatedMeeting = _meeting.copyWith(minutes: minutes ?? 'Failed to generate minutes.');
      await context.read<MeetingProvider>().updateMeeting(updatedMeeting);

      if (mounted) {
        setState(() {
          _meeting = updatedMeeting;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating minutes: $e')),
        );
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _exportToWord() async {
    setState(() {
      _isExporting = true;
    });

    final path = await _exportService.exportToWord(_meeting);

    if (path != null && mounted) {
      setState(() {
        _isExporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported successfully'),
          action: SnackBarAction(
            label: 'Share',
            onPressed: () {
              Share.shareXFiles([XFile(path)], text: 'Meeting Minutes');
            },
          ),
        ),
      );
    } else if (mounted) {
      setState(() {
        _isExporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_meeting.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isExporting ? null : _exportToWord,
            tooltip: 'Export to Word',
          ),
        ],
      ),
      body: _isGenerating || _isExporting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Date: ${_meeting.startTime.toString().substring(0, 16)}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          if (_meeting.endTime != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Duration: ${_calculateDuration(_meeting.startTime, _meeting.endTime!)}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.text_snippet),
                      const SizedBox(width: 8),
                      const Text(
                        'Transcript',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _meeting.transcript.isEmpty ? 'No transcript available.' : _meeting.transcript,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome),
                      const SizedBox(width: 8),
                      const Text(
                        'Meeting Minutes',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (_meeting.minutes.isEmpty)
                        TextButton.icon(
                          onPressed: _isGenerating ? null : _generateMinutes,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh),
                          label: const Text('Generate'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: _meeting.minutes.isEmpty
                        ? const Text(
                            'No minutes generated yet. Tap "Generate" to create AI-powered meeting minutes.',
                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                          )
                        : Text(
                            _meeting.minutes,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportToWord,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_download),
                      label: const Text('Export to Word'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
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
