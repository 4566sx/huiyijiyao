import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/speech_service.dart';
import '../services/whisper_service.dart';
import '../services/api_service.dart';
import '../services/export_service.dart';
import '../models/meeting.dart';
import '../models/ai_config.dart';
import '../providers/meeting_provider.dart';
import '../providers/config_provider.dart';
import '../widgets/record_button.dart';
import '../widgets/transcript_view.dart';
import 'minutes_screen.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final SpeechService _speechService = SpeechService();
  final WhisperService _whisperService = WhisperService();
  final ApiService _apiService = ApiService();
  final ExportService _exportService = ExportService();

  bool _isRecording = false;
  bool _isProcessing = false;
  String _transcript = '';
  String _meetingTitle = '';
  Timer? _timer;
  Duration _recordingDuration = Duration.zero;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _speechService.dispose();
    _whisperService.dispose();
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _isProcessing = true;
    });

    final initialized = await _speechService.initialize();
    if (!initialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize speech recognition')),
        );
        setState(() {
          _isProcessing = false;
        });
      }
      return;
    }

    setState(() {
      _meetingTitle = 'Meeting ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}';
      _transcript = '';
      _recordingDuration = Duration.zero;
      _isRecording = true;
      _isProcessing = false;
    });

    await _speechService.startRecording();

    await _speechService.startListening(
      onResult: (text) {
        setState(() {
          _transcript = text;
        });
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      },
    );

    _startTimer();
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    _timer?.cancel();

    await _speechService.stopListening();
    final audioPath = await _speechService.stopRecording();

    if (audioPath != null && _transcript.isEmpty) {
      await _processOfflineTranscription(audioPath);
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processOfflineTranscription(String audioPath) async {
    setState(() {
      _isProcessing = true;
    });

    final initialized = await _whisperService.initialize(
      onProgressUpdate: (progress) {
        if (mounted) {
          setState(() {});
        }
      },
    );

    if (initialized) {
      final result = await _whisperService.transcribe(audioPath);
      if (result != null && result.isNotEmpty) {
        setState(() {
          _transcript = result;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _generateMinutes() async {
    if (_transcript.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transcript to generate minutes from')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final configProvider = context.read<ConfigProvider>();
    final config = configProvider.currentConfig;

    if (config == null || config.apiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please configure AI settings first')),
        );
        setState(() {
          _isProcessing = false;
        });
      }
      return;
    }

    try {
      final minutes = await _apiService.generateMinutes(config, _transcript);

      final meeting = Meeting(
        title: _meetingTitle,
        startTime: DateTime.now().subtract(_recordingDuration),
        endTime: DateTime.now(),
        transcript: _transcript,
        minutes: minutes ?? 'Failed to generate minutes.',
      );

      await context.read<MeetingProvider>().createMeeting(meeting);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MinutesScreen(meeting: meeting),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating minutes: $e')),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _saveDraft() async {
    final meeting = Meeting(
      title: _meetingTitle,
      startTime: DateTime.now().subtract(_recordingDuration),
      endTime: DateTime.now(),
      transcript: _transcript,
    );

    await context.read<MeetingProvider>().createMeeting(meeting);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meeting saved as draft')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _exportToWord(Meeting meeting) async {
    final path = await _exportService.exportToWord(meeting);
    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to: $path')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Meeting Title',
          ),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          onChanged: (value) {
            _meetingTitle = value;
          },
          controller: TextEditingController(text: _meetingTitle),
        ),
        actions: [
          if (!_isRecording && _transcript.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveDraft,
              tooltip: 'Save Draft',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isRecording ? Icons.fiber_manual_record : Icons.pause_circle_outline,
                  color: _isRecording ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_recordingDuration),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TranscriptView(
                transcript: _transcript,
                controller: _scrollController,
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    _whisperService.isDownloading
                        ? 'Downloading model... ${(_whisperService.downloadProgress * 100).toStringAsFixed(0)}%'
                        : 'Processing...',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_isRecording && _transcript.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _generateMinutes,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Minutes'),
                  ),
                RecordButton(
                  isRecording: _isRecording,
                  onPressed: _isProcessing ? () {} : _toggleRecording,
                  size: 72,
                ),
                if (!_isRecording && _transcript.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _saveDraft,
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Save'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
