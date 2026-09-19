import 'package:flutter/material.dart';

import '../models/match.dart';
import '../services/match_repository.dart';
import 'home_screen.dart';

class MatchDetailsScreen extends StatefulWidget {
  const MatchDetailsScreen({super.key, required this.matchId});
  final String matchId;

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  late final stream = MatchRepository.instance.watchMatch(widget.matchId);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Match details')),
    body: StreamBuilder<Match?>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Could not load match: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(
            child: Text(
              snapshot.connectionState == ConnectionState.waiting
                  ? 'Loading match…'
                  : 'Match not found',
            ),
          );
        }
        final match = snapshot.data!;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        StatusBadge(status: match.status),
                        const SizedBox(height: 20),
                        const Text(
                          'MATCH SCORE',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _scoreColumn(match.teamA, match.scoreA),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'VS',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                            Expanded(
                              child: _scoreColumn(match.teamB, match.scoreB),
                            ),
                          ],
                        ),
                        if (match.status == MatchStatus.live) ...[
                          const SizedBox(height: 20),
                          const Text(
                            '● LIVE NOW · Scores update automatically',
                            style: TextStyle(
                              color: Color(0xFFFF655D),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MATCH INFORMATION',
                          style: TextStyle(
                            color: scoreAccent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _detail(
                          Icons.calendar_today_outlined,
                          'Date & time',
                          formatMatchDate(match.matchDate),
                        ),
                        const SizedBox(height: 16),
                        _detail(
                          Icons.location_on_outlined,
                          'Venue',
                          match.venue.isEmpty ? 'Not specified' : match.venue,
                        ),
                        if (match.details.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _detail(
                            Icons.info_outline,
                            'More information',
                            match.details,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _scoreColumn(String team, int score) => Column(
    children: [
      Text(
        team,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      Text(
        '$score',
        style: const TextStyle(
          fontSize: 54,
          fontWeight: FontWeight.w900,
          color: scoreAccent,
        ),
      ),
    ],
  );

  Widget _detail(IconData icon, String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.white60, size: 21),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ],
  );
}
