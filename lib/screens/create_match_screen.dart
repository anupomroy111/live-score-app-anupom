import 'package:flutter/material.dart';

import '../models/match.dart';
import '../services/match_repository.dart';
import 'home_screen.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final formKey = GlobalKey<FormState>();
  final teamA = TextEditingController();
  final teamB = TextEditingController();
  final venue = TextEditingController();
  final details = TextEditingController();
  DateTime matchDate = DateTime.now().add(const Duration(days: 1));
  bool saving = false;

  @override
  void dispose() {
    teamA.dispose();
    teamB.dispose();
    venue.dispose();
    details.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: matchDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(matchDate),
    );
    if (time == null || !mounted) return;
    setState(
      () => matchDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> create() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await MatchRepository.instance.createMatch(
        teamA: teamA.text,
        teamB: teamB.text,
        matchDate: matchDate,
        venue: venue.text,
        details: details.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match added to Firestore')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not add match: $error')));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add match')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'NEW FIXTURE',
                style: TextStyle(
                  color: scoreAccent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set up a match.',
                style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 24),
              _field(teamA, 'Team A', required: true),
              const SizedBox(height: 14),
              _field(teamB, 'Team B', required: true),
              const SizedBox(height: 14),
              _field(venue, 'Venue', required: true),
              const SizedBox(height: 14),
              _field(details, 'Additional information', maxLines: 3),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: pickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(formatMatchDate(matchDate)),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: saving ? null : create,
                icon: const Icon(Icons.add),
                label: Text(saving ? 'Adding…' : 'Create match'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    maxLength: maxLines == 1 ? 80 : 400,
    textCapitalization: TextCapitalization.sentences,
    decoration: InputDecoration(labelText: label),
    validator: required
        ? (value) => (value?.trim().isEmpty ?? true) ? 'Enter $label' : null
        : null,
  );
}
