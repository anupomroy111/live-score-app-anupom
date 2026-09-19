import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match.dart';

class MatchRepository {
  MatchRepository._();

  static final instance = MatchRepository._();

  final CollectionReference<Map<String, dynamic>> _matches = FirebaseFirestore
      .instance
      .collection('matches');

  Stream<List<Match>> watchMatches() => _matches
      .orderBy('matchDate')
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Match.fromDocument).toList());

  Stream<Match?> watchMatch(String id) => _matches
      .doc(id)
      .snapshots()
      .map((snapshot) => snapshot.exists ? Match.fromDocument(snapshot) : null);

  Future<void> createMatch({
    required String teamA,
    required String teamB,
    required DateTime matchDate,
    required String venue,
    required String details,
  }) async {
    await _matches.add({
      'teamA': teamA.trim(),
      'teamB': teamB.trim(),
      'scoreA': 0,
      'scoreB': 0,
      'status': MatchStatus.upcoming.label,
      'matchDate': Timestamp.fromDate(matchDate),
      'venue': venue.trim(),
      'details': details.trim(),
    });
  }

  Future<void> updateScore({
    required String id,
    required int scoreA,
    required int scoreB,
    required MatchStatus status,
  }) => _matches.doc(id).update({
    'scoreA': scoreA,
    'scoreB': scoreB,
    'status': status.label,
  });
}
