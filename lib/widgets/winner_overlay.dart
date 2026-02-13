import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shuffleboard_flutter/widgets/scoreboard_button.dart';

class WinnerOverlay extends StatefulWidget {
  const WinnerOverlay({
    super.key,
    required this.winnerLabel,
    required this.winnerColor,
    required this.onNewGame,
    this.resultFuture,
  });

  final String winnerLabel;
  final Color winnerColor;
  final VoidCallback onNewGame;
  final Future<(bool, String?)>? resultFuture;

  @override
  State<WinnerOverlay> createState() => _WinnerOverlayState();
}

class _WinnerOverlayState extends State<WinnerOverlay> {
  bool _resultDone = false;
  bool _resultFailed = false;
  String? _errorMessage;
  Timer? _autoResetTimer;

  @override
  void initState() {
    super.initState();
    if (widget.resultFuture != null) {
      widget.resultFuture!.then((result) {
        final (success, errorMessage) = result;
        if (mounted) {
          setState(() {
            _resultDone = true;
            _resultFailed = !success;
            _errorMessage = errorMessage;
          });
          _autoResetTimer = Timer(const Duration(minutes: 5), () {
            if (mounted) widget.onNewGame();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _autoResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showButton = widget.resultFuture == null || _resultDone;

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 80, color: widget.winnerColor),
            const SizedBox(height: 24),
            Text(
              widget.winnerLabel,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: widget.winnerColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'vinner!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: widget.winnerColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 48),
            if (widget.resultFuture != null && !_resultDone)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Registrerar resultat...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            if (widget.resultFuture != null && _resultDone && !_resultFailed)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Resultat registrerat!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.withValues(alpha: 0.8),
                  ),
                ),
              ),
            if (widget.resultFuture != null && _resultDone && _resultFailed)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Kunde inte registrera resultat',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.withValues(alpha: 0.8),
                      ),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            if (showButton)
              ScoreboardButton(
                onPressed: widget.onNewGame,
                icon: Icons.arrow_back,
                label: 'Tillbaka',
              ),
          ],
        ),
      ),
    );
  }
}
