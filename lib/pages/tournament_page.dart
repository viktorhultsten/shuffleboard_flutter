import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shuffleboard_flutter/app_config.dart';

const _registerBaseUrl = '${AppConfig.baseUrl}/register';
const _apiKey = 'dev-api-key-123';
const _pollInterval = Duration(seconds: 1);
const _inactivityTimeout = Duration(minutes: 5);

class TournamentPage extends StatefulWidget {
  const TournamentPage({super.key});

  @override
  State<TournamentPage> createState() => _TournamentPageState();
}

class _TournamentPageState extends State<TournamentPage> {
  Timer? _pollTimer;
  Timer? _timeoutTimer;
  String? _code;
  String? _error;
  bool _filling = false;

  @override
  void initState() {
    super.initState();
    _initiate();
  }

  Future<void> _initiate() async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/initiate'),
        headers: {'x-api-key': _apiKey},
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _code = data['code'] as String;
        });
        _startPolling();
        _resetTimeout();
      } else {
        setState(() {
          _error = 'Kunde inte starta turnering';
        });
      }
    } catch (error, stack) {
      print(error);
      print(stack);

      if (mounted) {
        setState(() {
          _error = 'Kunde inte ansluta till servern';
        });
      }
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkStatus());
  }

  void _resetTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_inactivityTimeout, () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _checkStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/tournament/status'),
        headers: {'x-api-key': _apiKey},
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String;
        if (status == 'filling' && !_filling) {
          setState(() => _filling = true);
        } else if (status == 'done') {
          _pollTimer?.cancel();
          _timeoutTimer?.cancel();
          final blueTeam = data['blueTeam'] as String;
          final redTeam = data['redTeam'] as String;
          if (mounted) {
            Navigator.of(
              context,
            ).pop({'blueTeam': blueTeam, 'redTeam': redTeam});
          }
        }
      }
    } catch (_) {
      // Network error — keep polling
    }
  }

  Future<void> _cancelSession() async {
    try {
      await http.post(
        Uri.parse('${AppConfig.baseUrl}/cancel'),
        headers: {'x-api-key': _apiKey},
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    if (_code != null) _cancelSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Stack(
          children: [
            Center(child: _buildContent()),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }

    if (_code == null) {
      return CircularProgressIndicator(
        color: Colors.white.withValues(alpha: 0.5),
      );
    }

    if (_filling) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit_note,
            size: 48,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'Väntar på lagnamn...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
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
                'Någon fyller i formuläret...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      );
    }

    final qrUrl = '$_registerBaseUrl?code=$_code';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Skanna QR-koden för att fylla i lagnamn',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: QrImageView(data: qrUrl, version: QrVersions.auto, size: 200),
        ),
      ],
    );
  }
}
