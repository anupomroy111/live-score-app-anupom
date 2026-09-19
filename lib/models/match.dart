import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchStatus { upcoming, live, finished }

extension MatchStatusLabel on MatchStatus {
  String get label => switch (this) {
    MatchStatus.upcoming => 'Upcoming',
    MatchStatus.live => 'Live',
    MatchStatus.finished => 'Finished',
  };
}

class Match {
  const Match({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.scoreA,
    required this.scoreB,
    required this.status,
    required this.matchDate,
    required this.venue,
    required this.details,
  });

  final String id;
  final String teamA;
  final String teamB;
  final int scoreA;
  final int scoreB;
  final MatchStatus status;
  final DateTime matchDate;
  final String venue;
  final String details;

  factory Match.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? <String, dynamic>{};
    final rawDate = data['matchDate'];
    return Match(
      id: document.id,
      teamA: (data['teamA'] as String?)?.trim().isNotEmpty == true
          ? data['teamA'] as String
          : 'Team A',
      teamB: (data['teamB'] as String?)?.trim().isNotEmpty == true
          ? data['teamB'] as String
          : 'Team B',
      scoreA: _score(data['scoreA']),
      scoreB: _score(data['scoreB']),
      status: MatchStatus.values.firstWhere(
        (status) =>
            status.label.toLowerCase() ==
            data['status'].toString().toLowerCase(),
        orElse: () => MatchStatus.upcoming,
      ),
      matchDate: rawDate is Timestamp
          ? rawDate.toDate()
          : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(),
      venue: data['venue']?.toString() ?? '',
      details: data['details']?.toString() ?? '',
    );
  }

  static int _score(Object? value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
}

String formatMatchDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]} ${date.year} · $hour:$minute ${date.hour < 12 ? 'AM' : 'PM'}';
}
