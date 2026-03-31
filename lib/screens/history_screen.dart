import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meeting_provider.dart';
import '../widgets/minutes_card.dart';
import 'minutes_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting History'),
      ),
      body: Consumer<MeetingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.meetings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No meeting history',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your recorded meetings will appear here',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadMeetings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.meetings.length,
              itemBuilder: (context, index) {
                final meeting = provider.meetings[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MinutesCard(
                    meeting: meeting,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MinutesScreen(meeting: meeting),
                        ),
                      );
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Meeting'),
                          content: const Text('Are you sure you want to delete this meeting? This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                provider.deleteMeeting(meeting.id!);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
