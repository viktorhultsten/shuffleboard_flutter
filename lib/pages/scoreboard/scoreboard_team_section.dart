import 'package:flutter/material.dart';

class ScoreboardTeamSection extends StatelessWidget {
  final int score;
  final Function(int i) onChange;
  final Color color;

  const ScoreboardTeamSection({
    super.key,
    required this.score,
    required this.onChange,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            IconButton(
              onPressed: () => onChange(1),
              icon: Icon(Icons.arrow_upward, size: 48, color: Colors.white),
            ),
            Text(
              score.toString(),
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () => onChange(-1),
              icon: Icon(Icons.arrow_downward, size: 48, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
