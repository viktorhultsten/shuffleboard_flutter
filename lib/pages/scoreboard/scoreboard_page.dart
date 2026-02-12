import 'package:flutter/material.dart';
import 'package:shuffleboard_flutter/pages/scoreboard/scoreboard_team_section.dart';

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  int redScore = 0;
  int blueScore = 0;

  void _onScoreChange(int delta, {required bool isRed}) {
    final newScore = (isRed ? redScore : blueScore) + delta;
    if (newScore < 0) return;
    setState(() {
      if (isRed) {
        redScore = newScore;
      } else {
        blueScore = newScore;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: ScoreboardTeamSection(
              score: redScore,
              color: const Color(0xFFD32F2F),
              onChange: (i) => _onScoreChange(i, isRed: true),
            ),
          ),
          Expanded(
            child: ScoreboardTeamSection(
              score: blueScore,
              color: const Color(0xFF1976D2),
              onChange: (i) => _onScoreChange(i, isRed: false),
            ),
          ),
        ],
      ),
    );
  }
}
