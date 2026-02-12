import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    MaterialApp(
      home: MouseRegion(
        cursor: SystemMouseCursors.none,
        child: ShuffleboardApp(),
      ),
    ),
  );
}

class ShuffleboardApp extends StatelessWidget {
  const ShuffleboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shuffleboard Scoreboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Roboto'),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121220),
      body: Row(
        children: [
          // Left half: QR code
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF121220),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SKANNA FÖR TURNERING',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: 'https://shuffleboard.snubbe.se',
                      version: QrVersions.auto,
                      size: 250,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'shuffleboard.snubbe.se',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withAlpha(100),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          Container(
            width: 2,
            color: Colors.white.withAlpha(20),
          ),
          // Right half: Play without tournament button
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF121220),
                  ],
                ),
              ),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ScoreboardScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    'SPELA UTANFÖR TURNERING',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen>
    with TickerProviderStateMixin {
  int _scoreLeft = 0;
  int _scoreRight = 0;
  int _round = 1;
  int _targetScore = 15;
  String _nameLeft = 'BLUE';
  String _nameRight = 'RED';
  Color _colorLeft = const Color(0xFF1565C0);
  Color _colorRight = const Color(0xFFC62828);

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String? _winner;

  static const List<Color> _teamColors = [
    Color(0xFF1565C0), // Blue
    Color(0xFFC62828), // Red
    Color(0xFF2E7D32), // Green
    Color(0xFFE65100), // Orange
    Color(0xFF6A1B9A), // Purple
    Color(0xFF00838F), // Teal
    Color(0xFFAD1457), // Pink
    Color(0xFF4E342E), // Brown
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _addScore(bool isLeft, int points) {
    if (_winner != null) return;
    setState(() {
      if (isLeft) {
        _scoreLeft = (_scoreLeft + points).clamp(0, 99);
      } else {
        _scoreRight = (_scoreRight + points).clamp(0, 99);
      }
      _checkWinner();
    });
  }

  void _checkWinner() {
    if (_scoreLeft >= _targetScore) {
      _winner = _nameLeft;
    } else if (_scoreRight >= _targetScore) {
      _winner = _nameRight;
    }
  }

  void _nextRound() {
    setState(() {
      _round++;
      _winner = null;
      _scoreLeft = 0;
      _scoreRight = 0;
    });
  }

  void _resetGame() {
    setState(() {
      _scoreLeft = 0;
      _scoreRight = 0;
      _round = 1;
      _winner = null;
    });
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        int tempTarget = _targetScore;
        String tempNameLeft = _nameLeft;
        String tempNameRight = _nameRight;
        Color tempColorLeft = _colorLeft;
        Color tempColorRight = _colorRight;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF1E1E2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(28),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'GAME SETTINGS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      _buildTeamSettingsRow(
                        'Left Team',
                        tempNameLeft,
                        tempColorLeft,
                        (name) {
                          setDialogState(() => tempNameLeft = name);
                        },
                        (color) {
                          setDialogState(() => tempColorLeft = color);
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTeamSettingsRow(
                        'Right Team',
                        tempNameRight,
                        tempColorRight,
                        (name) {
                          setDialogState(() => tempNameRight = name);
                        },
                        (color) {
                          setDialogState(() => tempColorRight = color);
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'TARGET SCORE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Colors.white54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int target in [11, 15, 21])
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: ChoiceChip(
                                label: Text(
                                  '$target',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: tempTarget == target
                                        ? Colors.black
                                        : Colors.white70,
                                  ),
                                ),
                                selected: tempTarget == target,
                                selectedColor: Colors.amber,
                                backgroundColor: const Color(0xFF2A2A3E),
                                onSelected: (_) {
                                  setDialogState(() => tempTarget = target);
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'CANCEL',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 15,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _targetScore = tempTarget;
                                  if (tempNameLeft.trim().isNotEmpty) {
                                    _nameLeft = tempNameLeft
                                        .trim()
                                        .toUpperCase();
                                  }
                                  if (tempNameRight.trim().isNotEmpty) {
                                    _nameRight = tempNameRight
                                        .trim()
                                        .toUpperCase();
                                  }
                                  _colorLeft = tempColorLeft;
                                  _colorRight = tempColorRight;
                                });
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'APPLY',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTeamSettingsRow(
    String label,
    String currentName,
    Color currentColor,
    ValueChanged<String> onNameChanged,
    ValueChanged<Color> onColorChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: currentName,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2A2A3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                onChanged: onNameChanged,
              ),
            ),
            const SizedBox(width: 12),
            Wrap(
              spacing: 6,
              children: _teamColors.map((color) {
                final isSelected = color.toARGB32() == currentColor.toARGB32();
                return GestureDetector(
                  onTap: () => onColorChanged(color),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2.5)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withAlpha(120),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121220),
      body: Stack(
        children: [
          // Main scoreboard
          Row(
            children: [
              // Left team
              Expanded(
                child: _buildTeamSide(
                  name: _nameLeft,
                  score: _scoreLeft,
                  color: _colorLeft,
                  isLeft: true,
                ),
              ),
              // Center divider with round info
              _buildCenterDivider(),
              // Right team
              Expanded(
                child: _buildTeamSide(
                  name: _nameRight,
                  score: _scoreRight,
                  color: _colorRight,
                  isLeft: false,
                ),
              ),
            ],
          ),
          // Winner overlay
          if (_winner != null) _buildWinnerOverlay(),
          // Settings button
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              onPressed: _showSettings,
              icon: const Icon(Icons.settings, color: Colors.white24, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSide({
    required String name,
    required int score,
    required Color color,
    required bool isLeft,
  }) {
    final isLeading = isLeft
        ? _scoreLeft > _scoreRight
        : _scoreRight > _scoreLeft;

    return GestureDetector(
      onTap: () => _addScore(isLeft, 1),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
            colors: [color.withAlpha(60), color.withAlpha(15)],
          ),
        ),
        child: Column(
          children: [
            // Team name bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: color.withAlpha(70),
                border: Border(
                  bottom: BorderSide(color: color.withAlpha(100), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLeading && _winner == null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.arrow_right,
                        color: color.withAlpha(200),
                        size: 28,
                      ),
                    ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                      color: Colors.white.withAlpha(220),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Score display
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Score
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isLeading && _winner == null
                              ? _pulseAnimation.value
                              : 1.0,
                          child: child,
                        );
                      },
                      child: Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 180,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withAlpha(240),
                          height: 1,
                          shadows: [
                            Shadow(color: color.withAlpha(120), blurRadius: 40),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress bar to target
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (score / _targetScore).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.white.withAlpha(15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            color.withAlpha(180),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$score / $_targetScore',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(80),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Score buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildScoreButton(
                    label: '-1',
                    onTap: () => _addScore(isLeft, -1),
                    color: color,
                    isSubtract: true,
                  ),
                  const SizedBox(width: 12),
                  _buildScoreButton(
                    label: '+1',
                    onTap: () => _addScore(isLeft, 1),
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  _buildScoreButton(
                    label: '+2',
                    onTap: () => _addScore(isLeft, 2),
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  _buildScoreButton(
                    label: '+3',
                    onTap: () => _addScore(isLeft, 3),
                    color: color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
    bool isSubtract = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 72,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isSubtract
                ? Colors.white.withAlpha(15)
                : color.withAlpha(50),
            border: Border.all(
              color: isSubtract
                  ? Colors.white.withAlpha(30)
                  : color.withAlpha(80),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isSubtract
                  ? Colors.white.withAlpha(120)
                  : Colors.white.withAlpha(220),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterDivider() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border.symmetric(
          vertical: BorderSide(color: Colors.white.withAlpha(15), width: 1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Round indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withAlpha(60)),
            ),
            child: Column(
              children: [
                Text(
                  'RND',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: Colors.amber.withAlpha(180),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_round',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.amber.withAlpha(220),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // VS text
          Text(
            'VS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.white.withAlpha(40),
            ),
          ),
          const Spacer(),
          // Reset button
          Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Reset Game?',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'This will reset all scores and the round counter.',
                      style: TextStyle(color: Colors.white60),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resetGame();
                        },
                        child: const Text(
                          'RESET',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(
                Icons.refresh,
                color: Colors.white.withAlpha(50),
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerOverlay() {
    final winnerColor = _winner == _nameLeft ? _colorLeft : _colorRight;

    return AnimatedOpacity(
      opacity: _winner != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        color: Colors.black.withAlpha(200),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.amber.withAlpha(230),
              ),
              const SizedBox(height: 16),
              Text(
                '$_winner WINS!',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: winnerColor.withAlpha(180), blurRadius: 30),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Round $_round  •  $_scoreLeft - $_scoreRight',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white.withAlpha(140),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _resetGame();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withAlpha(60)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'NEW GAME',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _nextRound,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'NEXT ROUND',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
