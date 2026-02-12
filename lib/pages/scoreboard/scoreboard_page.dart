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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB71C1C),
              Color(0xFF880E4F),
              Color(0xFF4A148C),
              Color(0xFF283593),
              Color(0xFF0D47A1),
            ],
            stops: [0.0, 0.35, 0.5, 0.65, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: ScoreboardTeamSection(
                score: redScore,
                onChange: (i) => _onScoreChange(i, isRed: true),
                rightSide: false,
              ),
            ),
            Expanded(
              child: ScoreboardTeamSection(
                score: blueScore,
                onChange: (i) => _onScoreChange(i, isRed: false),
                rightSide: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
