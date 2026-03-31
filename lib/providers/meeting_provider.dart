import 'package:flutter/material.dart';
import '../models/meeting.dart';
import '../services/storage_service.dart';

class MeetingProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Meeting> _meetings = [];
  Meeting? _currentMeeting;
  bool _isLoading = false;
  String? _error;

  List<Meeting> get meetings => _meetings;
  Meeting? get currentMeeting => _currentMeeting;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMeetings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _meetings = await _storage.getMeetings();
    } catch (e) {
      _error = 'Failed to load meetings: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createMeeting(Meeting meeting) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _storage.insertMeeting(meeting);
      _currentMeeting = meeting.copyWith(id: id);
      await loadMeetings();
    } catch (e) {
      _error = 'Failed to create meeting: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateMeeting(Meeting meeting) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storage.updateMeeting(meeting);
      _currentMeeting = meeting;
      await loadMeetings();
    } catch (e) {
      _error = 'Failed to update meeting: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteMeeting(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storage.deleteMeeting(id);
      if (_currentMeeting?.id == id) {
        _currentMeeting = null;
      }
      await loadMeetings();
    } catch (e) {
      _error = 'Failed to delete meeting: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCurrentMeeting(Meeting meeting) {
    _currentMeeting = meeting;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
