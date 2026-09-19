import 'package:flutter/material.dart';

import '../models/match.dart';
import '../services/match_repository.dart';
import 'match_details_screen.dart';
import 'score_admin_screen.dart';

const scoreAccent = Color(0xFFBDF75B);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final stream = MatchRepository.instance.watchMatches();
  MatchStatus? filter;
  String search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.sports_score, color: scoreAccent),
            SizedBox(width: 10),
            Text(
              'LIVE SCORE',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Score admin',
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScoreAdminScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: StreamBuilder<List<Match>>(
            stream: stream,
            builder: (context, snapshot) {
              final matches = snapshot.data ?? [];
              final liveCount = matches
                  .where((m) => m.status == MatchStatus.live)
                  .length;
              final visible = matches.where((m) {
                final query = search.toLowerCase();
                return (filter == null || m.status == filter) &&
                    (m.teamA.toLowerCase().contains(query) ||
                        m.teamB.toLowerCase().contains(query) ||
                        m.venue.toLowerCase().contains(query));
              }).toList();
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'THE GAME IS ON',
                            style: TextStyle(
                              color: scoreAccent,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Every score.\nAs it happens.',
                            style: TextStyle(
                              fontSize: 36,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '$liveCount live  ·  ${matches.length} total matches',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            onChanged: (value) =>
                                setState(() => search = value.trim()),
                            decoration: const InputDecoration(
                              hintText: 'Search teams or venue',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _filterChip('All', null),
                                for (final status in MatchStatus.values)
                                  _filterChip(status.label, status),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'MATCH CENTER',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (snapshot.hasError)
                    SliverFillRemaining(
                      child: _StateMessage(
                        icon: Icons.error_outline,
                        title: 'Could not load matches',
                        subtitle:
                            '${snapshot.error}\nCheck Firestore access and connection.',
                      ),
                    )
                  else if (!snapshot.hasData)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (visible.isEmpty)
                    SliverFillRemaining(
                      child: _StateMessage(
                        icon: Icons.sports_score_outlined,
                        title: matches.isEmpty
                            ? 'No matches yet'
                            : 'No matches found',
                        subtitle: matches.isEmpty
                            ? 'Open Score admin to add the first match.'
                            : 'Try another team, venue, or filter.',
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: visible.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: MatchCard(
                          match: visible[index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MatchDetailsScreen(
                                matchId: visible[index].id,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, MatchStatus? value) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: filter == value,
      onSelected: (_) => setState(() => filter = value),
      selectedColor: scoreAccent,
      labelStyle: TextStyle(
        color: filter == value ? const Color(0xFF091318) : Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class MatchCard extends StatelessWidget {
  const MatchCard({super.key, required this.match, required this.onTap});

  final Match match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: match.status),
                  const Icon(
                    Icons.arrow_outward,
                    size: 20,
                    color: Colors.white54,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _teamRow(match.teamA, match.scoreA),
              const SizedBox(height: 13),
              _teamRow(match.teamB, match.scoreB),
              const Divider(height: 30, color: Colors.white12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      formatMatchDate(match.matchDate),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (match.venue.isNotEmpty)
                    Flexible(
                      child: Text(
                        match.venue,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamRow(String name, int score) => Row(
    children: [
      Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF263A3E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          name.isEmpty ? '?' : name[0].toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: scoreAccent,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      Text(
        '$score',
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
      ),
    ],
  );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final MatchStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      MatchStatus.live => const Color(0xFFFF655D),
      MatchStatus.upcoming => const Color(0xFF83C7FF),
      MatchStatus.finished => Colors.white70,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            status.label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: scoreAccent),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    ),
  );
}
