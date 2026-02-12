import 'package:flutter/material.dart';
import 'package:shuffleboard_flutter/common/custom_icon_button.dart';

class ScoreboardTeamSection extends StatelessWidget {
  final int score;
  final Function(int i) onChange;
  final bool rightSide;
  final String teamName;

  const ScoreboardTeamSection({
    super.key,
    required this.score,
    required this.onChange,
    required this.rightSide,
    required this.teamName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
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
                      CustomIconButton(
                        onPressed: () => onChange(1),
                        iconData: Icons.arrow_upward,
                      ),
                      CustomIconButton(
                        onPressed: () => onChange(-1),
                        iconData: Icons.arrow_downward,
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
            Text(teamName, style: TextStyle(fontSize: 30, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
