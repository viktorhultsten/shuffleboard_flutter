import 'dart:math' as math;

import 'package:flutter/material.dart';

class FlipCounter extends StatelessWidget {
  const FlipCounter({
    super.key,
    required this.value,
    required this.color,
    this.fontSize = 140,
  });

  final int value;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final tens = (value ~/ 10) % 10;
    final ones = value % 10;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlipDigit(
          value: tens,
          color: color,
          fontSize: fontSize,
        ),
        SizedBox(width: fontSize * 0.06),
        FlipDigit(
          value: ones,
          color: color,
          fontSize: fontSize,
        ),
      ],
    );
  }
}

class FlipDigit extends StatefulWidget {
  const FlipDigit({
    super.key,
    required this.value,
    required this.color,
    this.fontSize = 140,
  });

  final int value;
  final Color color;
  final double fontSize;

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _previousValue = widget.value;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _currentValue = widget.value;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return _buildDisplay();
      },
    );
  }

  Widget _buildDisplay() {
    final animValue = _animation.value;
    final style = TextStyle(
      fontSize: widget.fontSize,
      fontWeight: FontWeight.bold,
      color: widget.color,
      height: 1.0,
    );
    final hPad = widget.fontSize * 0.2;
    final vPad = widget.fontSize * 0.15;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicWidth(
          child: Stack(
            children: [
              // Base layer
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHalf(
                    text: '$_currentValue',
                    style: style,
                    isTop: true,
                    hPad: hPad,
                    vPad: vPad,
                  ),
                  Container(height: 2, color: Colors.grey[900]),
                  _buildHalf(
                    text: '$_previousValue',
                    style: style,
                    isTop: false,
                    hPad: hPad,
                    vPad: vPad,
                  ),
                ],
              ),
              // Top flap: shows old value, flips away (first half of animation)
              if (animValue < 1.0)
                Positioned.fill(
                  bottom: null,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateX(animValue <= 0.5
                          ? -animValue * math.pi
                          : -math.pi / 2),
                    child: Opacity(
                      opacity: animValue <= 0.5 ? 1.0 : 0.0,
                      child: _buildHalf(
                        text: '$_previousValue',
                        style: style,
                        isTop: true,
                        hPad: hPad,
                        vPad: vPad,
                      ),
                    ),
                  ),
                ),
              // Bottom flap: shows new value, flips into place (second half)
              if (animValue > 0.0)
                Positioned.fill(
                  top: null,
                  child: Transform(
                    alignment: Alignment.topCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateX(animValue >= 0.5
                          ? (1.0 - animValue) * math.pi
                          : math.pi / 2),
                    child: Opacity(
                      opacity: animValue >= 0.5 ? 1.0 : 0.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(height: 2, color: Colors.grey[900]),
                          _buildHalf(
                            text: '$_currentValue',
                            style: style,
                            isTop: false,
                            hPad: hPad,
                            vPad: vPad,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHalf({
    required String text,
    required TextStyle style,
    required bool isTop,
    required double hPad,
    required double vPad,
  }) {
    return Container(
      padding: EdgeInsets.only(
        left: hPad,
        right: hPad,
        top: isTop ? vPad : 0,
        bottom: isTop ? 0 : vPad,
      ),
      decoration: BoxDecoration(
        color: isTop ? Colors.grey[850] : Colors.grey[800],
      ),
      child: ClipRect(
        child: Align(
          alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
          heightFactor: 0.5,
          child: Text(text, style: style),
        ),
      ),
    );
  }
}
