import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shuffleboard_flutter/app_config.dart';
import 'package:shuffleboard_flutter/pages/tournament_page.dart';
import 'package:shuffleboard_flutter/widgets/confirm_dialog.dart';
import 'package:shuffleboard_flutter/widgets/scoreboard_button.dart';
import 'package:shuffleboard_flutter/widgets/team_panel.dart';
import 'package:shuffleboard_flutter/widgets/winner_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shuffleboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.dark,
        ),
      ),
      home: const ScoreboardPage(),
    );
  }
}

Route<T> _fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 200),
  );
}

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({
    super.key,
    this.blueLabel = 'Team Blåbär',
    this.redLabel = 'Team Lingon',
  });

  final String blueLabel;
  final String redLabel;

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

const _apiKey = 'dev-api-key-123';

class _ScoreboardPageState extends State<ScoreboardPage> {
  int _blueScore = 0;
  int _redScore = 0;
  Future<(bool, String?)>? _resultFuture;

  bool get _isTournament =>
      widget.blueLabel != 'Team Blåbär' || widget.redLabel != 'Team Lingon';

  Future<(bool, String?)> _sendResult(String winner) async {
    try {
      final url = '${AppConfig.baseUrl}/tournament/result';
      final response = await http.post(
        Uri.parse(url),
        headers: {'x-api-key': _apiKey, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'blueTeam': widget.blueLabel,
          'redTeam': widget.redLabel,
          'blueScore': _blueScore,
          'redScore': _redScore,
          'winner': winner,
        }),
      );
      if (response.statusCode == 200) {
        return (true, null);
      }
      return (false, '$url → ${response.statusCode}: ${response.body}');
    } catch (e) {
      return (false, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? winnerLabel;
    final Color? winnerColor;
    if (_blueScore >= 15) {
      winnerLabel = widget.blueLabel;
      winnerColor = Colors.blue;
      if (_isTournament) _resultFuture ??= _sendResult(winnerLabel);
    } else if (_redScore >= 15) {
      winnerLabel = widget.redLabel;
      winnerColor = Colors.red;
      if (_isTournament) _resultFuture ??= _sendResult(winnerLabel);
    } else {
      winnerLabel = null;
      winnerColor = null;
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (_isTournament)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 16,
                          color: Colors.amber.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Turnering',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Material(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () async {
                              final confirmed = await showConfirmDialog(
                                context,
                                title: 'Avbryt turnering',
                                content:
                                    'Vill du avbryta turneringen och återställa lagnamnen?',
                              );
                              if (confirmed && context.mounted) {
                                Navigator.of(context).pushReplacement(
                                  _fadeRoute(const ScoreboardPage()),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Text(
                                'Avbryt turnering',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.amber.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Row(
                    children: [
                      TeamPanel(
                        color: Colors.blue,
                        score: _blueScore,
                        label: widget.blueLabel,
                        onScoreChange: (delta) => setState(() {
                          _blueScore = (_blueScore + delta).clamp(0, 99);
                        }),
                      ),
                      TeamPanel(
                        color: Colors.red,
                        score: _redScore,
                        label: widget.redLabel,
                        onScoreChange: (delta) => setState(() {
                          _redScore = (_redScore + delta).clamp(0, 99);
                        }),
                        reversed: true,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    border: Border(
                      top: BorderSide(color: Colors.grey[700]!, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScoreboardButton(
                        onPressed: () async {
                          final confirmed = await showConfirmDialog(
                            context,
                            title: 'Starta om',
                            content:
                                'Vill du nollställa poängen och återställa lagnamnen?',
                          );
                          if (confirmed && context.mounted) {
                            Navigator.of(context).pushReplacement(
                              _fadeRoute(const ScoreboardPage()),
                            );
                          }
                        },
                        icon: Icons.restart_alt,
                        label: 'Starta om',
                      ),
                      const SizedBox(width: 32),
                      ScoreboardButton(
                        onPressed: _isTournament
                            ? null
                            : () async {
                                final result = await Navigator.of(context)
                                    .push<Map<String, String>>(
                                      _fadeRoute(const TournamentPage()),
                                    );
                                if (result != null && context.mounted) {
                                  Navigator.of(context).pushReplacement(
                                    _fadeRoute(
                                      ScoreboardPage(
                                        blueLabel: result['blueTeam']!,
                                        redLabel: result['redTeam']!,
                                      ),
                                    ),
                                  );
                                }
                              },
                        icon: Icons.groups,
                        label: 'Turnering',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (winnerLabel != null && winnerColor != null)
              WinnerOverlay(
                winnerLabel: winnerLabel,
                winnerColor: winnerColor,
                resultFuture: _resultFuture,
                onNewGame: () {
                  Navigator.of(
                    context,
                  ).pushReplacement(_fadeRoute(const ScoreboardPage()));
                },
              ),
          ],
        ),
      ),
    );
  }
}
