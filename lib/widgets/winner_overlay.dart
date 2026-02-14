import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shuffleboard_flutter/widgets/scoreboard_button.dart';

class WinnerOverlay extends StatefulWidget {
  const WinnerOverlay({
    super.key,
    required this.winnerLabel,
    required this.winnerColor,
    required this.onNewGame,
    required this.blueLabel,
    required this.redLabel,
    required this.blueScore,
    required this.redScore,
    this.resultFuture,
  });

  final String winnerLabel;
  final Color winnerColor;
  final VoidCallback onNewGame;
  final String blueLabel;
  final String redLabel;
  final int blueScore;
  final int redScore;
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
    final blueWon = widget.winnerLabel == widget.blueLabel;

    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 72, color: widget.winnerColor),
            const SizedBox(height: 16),
            Text(
              '${widget.winnerLabel} vinner!',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: widget.winnerColor,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ScoreColumn(
                  label: widget.blueLabel,
                  score: widget.blueScore,
                  color: Colors.blue,
                  isWinner: blueWon,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '–',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                _ScoreColumn(
                  label: widget.redLabel,
                  score: widget.redScore,
                  color: Colors.red,
                  isWinner: !blueWon,
                ),
              ],
            ),
            const SizedBox(height: 40),
            if (widget.resultFuture != null) _buildResultStatus(),
            if (widget.resultFuture != null) const SizedBox(height: 24),
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

  Widget _buildResultStatus() {
    if (!_resultDone) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.amber.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Registrerar resultat...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.amber.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }

    if (!_resultFailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 20,
              color: Colors.green.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 12),
            Text(
              'Resultat registrerat!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.green.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 20,
                color: Colors.red.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 12),
              Text(
                'Kunde inte registrera resultat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  const _ScoreColumn({
    required this.label,
    required this.score,
    required this.color,
    required this.isWinner,
  });

  final String label;
  final int score;
  final Color color;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: color.withValues(alpha: isWinner ? 0.9 : 0.5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: isWinner ? 1.0 : 0.4),
          ),
        ),
      ],
    );
  }
}
