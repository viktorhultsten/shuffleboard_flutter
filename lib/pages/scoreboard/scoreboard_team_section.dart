import 'package:flutter/material.dart';

class ScoreboardTeamSection extends StatelessWidget {
  final int score;
  final Function(int i) onChange;
  final bool rightSide;

  const ScoreboardTeamSection({
    super.key,
    required this.score,
    required this.onChange,
    required this.rightSide,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SafeArea(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (rightSide)
                Expanded(
                  child: Center(
                    child: Text(
                      score.toString(),
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                children: [
                  IconButton(
                    onPressed: () => onChange(1),
                    icon: Icon(
                      Icons.arrow_upward,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),

                  IconButton(
                    onPressed: () => onChange(-1),
                    icon: Icon(
                      Icons.arrow_downward,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              if (!rightSide)
                Expanded(
                  child: Center(
                    child: Text(
                      score.toString(),
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
    );
  }
}
