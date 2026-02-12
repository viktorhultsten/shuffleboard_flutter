import 'package:flutter/material.dart';
import 'package:shuffleboard_flutter/pages/landing/qr_code_section.dart';
import 'package:shuffleboard_flutter/pages/scoreboard/scoreboard_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Center(child: QrCodeSection())),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: VerticalDivider(),
        ),
        Expanded(
          child: Center(
            child: FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => ScoreboardPage())),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Spela utan att registrera lag',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
