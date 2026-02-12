import 'package:flutter/material.dart';

class ScoreboardTeamSection extends StatelessWidget {
  final int score;
  final Function(int i) onChange;

  const ScoreboardTeamSection({
    super.key,
    required this.score,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        IconButton(
          onPressed: () => onChange(1),
          icon: Icon(Icons.arrow_upward, size: 40),
        ),
        Text(
          score.toString(),
          style: TextStyle(fontSize: 25), //
        ),
        IconButton(
          onPressed: () => onChange(-1),
          icon: Icon(Icons.arrow_downward, size: 40),
        ),
      ],
    );
  }
}
