import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shuffleboard_flutter/widgets/flip_counter.dart';

class TeamPanel extends StatefulWidget {
  const TeamPanel({
    super.key,
    required this.color,
    required this.score,
    required this.label,
    required this.onScoreChange,
    this.reversed = false,
  });

  final Color color;
  final int score;
  final String label;
  final ValueChanged<int> onScoreChange;
  final bool reversed;

  @override
  State<TeamPanel> createState() => _TeamPanelState();
}

class _TeamPanelState extends State<TeamPanel>
    with SingleTickerProviderStateMixin {
  static const _commitDuration = Duration(seconds: 3);

  int _pending = 0;
  int _lastNonZeroPending = 0;
  Timer? _timer;
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    _timerController =
        AnimationController(vsync: this, duration: _commitDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _commitPending();
            }
          });
  }

  void _adjustPending(int delta) {
    setState(() {
      _pending += delta;
      if (_pending != 0) _lastNonZeroPending = _pending;
    });
    _timer?.cancel();
    _timerController.forward(from: 0);
    _timer = Timer(_commitDuration, _commitPending);
  }

  void _commitPending() {
    _timer?.cancel();
    if (_pending != 0) {
      widget.onScoreChange(_pending);
      setState(() {
        _pending = 0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttons = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: widget.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _adjustPending(1),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Icon(
                  Icons.keyboard_arrow_up,
                  size: 48,
                  color: widget.color,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: widget.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _adjustPending(-1),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 48,
                  color: widget.color,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final pendingIndicator = SizedBox(
      width: 56,
      child: Center(
        child: AnimatedOpacity(
          opacity: _pending != 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _timerController,
                  builder: (context, _) {
                    return SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: 1.0 - _timerController.value,
                        strokeWidth: 3,
                        color: widget.color.withValues(alpha: 0.5),
                        backgroundColor: widget.color.withValues(alpha: 0.1),
                      ),
                    );
                  },
                ),
                Text(
                  '${_lastNonZeroPending > 0 ? '+' : ''}$_lastNonZeroPending',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: widget.color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final scoreDisplay = Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: widget.color.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          FlipCounter(value: widget.score, color: widget.color),
        ],
      ),
    );

    final children = widget.reversed
        ? [scoreDisplay, pendingIndicator, buttons]
        : [buttons, pendingIndicator, scoreDisplay];

    return Expanded(child: Row(children: children));
  }
}
