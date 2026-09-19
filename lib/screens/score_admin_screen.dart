import 'package:flutter/material.dart';

import '../models/match.dart';
import '../services/match_repository.dart';
import 'create_match_screen.dart';
import 'home_screen.dart';

class ScoreAdminScreen extends StatefulWidget {
  const ScoreAdminScreen({super.key});

  @override
  State<ScoreAdminScreen> createState() => _ScoreAdminScreenState();
}

class _ScoreAdminScreenState extends State<ScoreAdminScreen> {
  late final stream = MatchRepository.instance.watchMatches();
  String? selectedId;
  int? scoreA;
  int? scoreB;
  MatchStatus? status;
  bool saving = false;

  void select(Match match) => setState(() {
    selectedId = match.id;
    scoreA = match.scoreA;
    scoreB = match.scoreB;
    status = match.status;
  });

  Future<void> save() async {
    if (selectedId == null ||
        scoreA == null ||
        scoreB == null ||
        status == null) {
      return;
    }
    setState(() => saving = true);
    try {
      await MatchRepository.instance.updateScore(
        id: selectedId!,
        scoreA: scoreA!,
        scoreB: scoreB!,
        status: status!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Score updated in Firestore')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Update failed: $error')));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Score admin')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: StreamBuilder<List<Match>>(
          stream: stream,
          builder: (context, snapshot) {
            final matches = snapshot.data ?? [];
            final selected = matches
                .where((m) => m.id == selectedId)
                .firstOrNull;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'MANAGE MATCHES',
                  style: TextStyle(
                    color: scoreAccent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Keep the game moving.',
                  style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Changes saved here appear on every open match screen.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateMatchScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add a match'),
                ),
                const SizedBox(height: 24),
                if (snapshot.hasError)
                  Text('Could not load matches: ${snapshot.error}')
                else if (!snapshot.hasData)
                  const Center(child: CircularProgressIndicator())
                else if (matches.isEmpty)
                  const Text(
                    'No matches yet. Add one to start tracking scores.',
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    initialValue: selected == null ? null : selectedId,
                    decoration: const InputDecoration(
                      labelText: 'Select match',
                    ),
                    items: matches
                        .map(
                          (match) => DropdownMenuItem(
                            value: match.id,
                            child: Text(
                              '${match.teamA} vs ${match.teamB}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (id) {
                      final match = matches
                          .where((m) => m.id == id)
                          .firstOrNull;
                      if (match != null) select(match);
                    },
                  ),
                  if (selected != null &&
                      scoreA != null &&
                      scoreB != null &&
                      status != null) ...[
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _scoreControl(
                              selected.teamA,
                              scoreA!,
                              (value) => setState(() => scoreA = value),
                            ),
                            const Divider(height: 30),
                            _scoreControl(
                              selected.teamB,
                              scoreB!,
                              (value) => setState(() => scoreB = value),
                            ),
                            const SizedBox(height: 22),
                            DropdownButtonFormField<MatchStatus>(
                              initialValue: status,
                              decoration: const InputDecoration(
                                labelText: 'Match status',
                              ),
                              items: MatchStatus.values
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => status = value),
                            ),
                            const SizedBox(height: 22),
                            FilledButton.icon(
                              onPressed: saving ? null : save,
                              icon: saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                saving ? 'Updating…' : 'Update score',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    ),
  );

  Widget _scoreControl(String team, int value, ValueChanged<int> onChange) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            team,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Decrease $team score',
                onPressed: value > 0 ? () => onChange(value - 1) : null,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Increase $team score',
                onPressed: () => onChange(value + 1),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      );
}
