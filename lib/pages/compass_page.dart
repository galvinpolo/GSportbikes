import 'package:flutter/material.dart';
import 'dart:async';
import '../services/compass_service.dart';
import '../widgets/compass_widget.dart';

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  double _currentHeading = 0.0;
  StreamSubscription<double>? _compassSubscription;
  bool _isCompassActive = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startCompass();
  }

  @override
  void dispose() {
    _stopCompass();
    CompassService.dispose();
    super.dispose();
  }

  void _startCompass() {
    try {
      setState(() {
        _isCompassActive = true;
        _errorMessage = '';
      });

      CompassService.startCompass();

      _compassSubscription = CompassService.compassStream.listen(
        (double heading) {
          setState(() {
            _currentHeading = heading;
          });
        },
        onError: (error) {
          setState(() {
            _errorMessage = 'Compass error: $error';
            _isCompassActive = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to start compass: $e';
        _isCompassActive = false;
      });
    }
  }

  void _stopCompass() {
    _compassSubscription?.cancel();
    CompassService.stopCompass();
    setState(() {
      _isCompassActive = false;
    });
  }

  void _toggleCompass() {
    if (_isCompassActive) {
      _stopCompass();
    } else {
      _startCompass();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Compass',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _toggleCompass,
            icon: Icon(
              _isCompassActive ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            tooltip: _isCompassActive ? 'Stop Compass' : 'Start Compass',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status indicator
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _isCompassActive
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                ),
                child: Column(
                  children: [
                    Icon(
                      _isCompassActive ? Icons.explore : Icons.explore_off,
                      size: 32,
                      color: _isCompassActive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isCompassActive ? 'Compass Active' : 'Compass Inactive',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isCompassActive
                            ? Colors.green[800]
                            : Colors.red[800],
                      ),
                    ),
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Compass widget
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: CompassWidget(
                  heading: _currentHeading,
                  size: 280,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Heading information
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.navigation,
                          color: Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_currentHeading.toStringAsFixed(1)}°',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CompassService.getFullDirectionName(_currentHeading),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CompassService.getDirectionName(_currentHeading),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'How to use',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      '1. Hold your device flat and level',
                      Icons.phone_android,
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem(
                      '2. Move away from metal objects',
                      Icons.warning_amber,
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem(
                      '3. Calibrate by moving in figure-8 pattern',
                      Icons.refresh,
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem(
                      '4. Red needle points to magnetic North',
                      Icons.north,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
