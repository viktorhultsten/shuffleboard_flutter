import 'package:flutter/material.dart';
import '../../common/custom_icon_button.dart';
import 'scoreboard_team_section.dart';

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  int redScore = 0;
  int blueScore = 0;

  void _resetScores() {
    setState(() {
      redScore = 0;
      blueScore = 0;
    });
  }

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
                teamName: 'Team red',
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 50,
              children: [
                CustomIconButton(
                  onPressed: _resetScores,
                  iconData: Icons.refresh,
                ),
                CustomIconButton(
                  onPressed: () => Navigator.pop(context),
                  iconData: Icons.home,
                ),
              ],
            ),
            Expanded(
              child: ScoreboardTeamSection(
                score: blueScore,
                onChange: (i) => _onScoreChange(i, isRed: false),
                rightSide: true,
                teamName: 'Team blue',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
