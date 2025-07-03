import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fft/flutter_fft.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AudioVisualizer(),
    );
  }
}

class AudioVisualizer extends StatefulWidget {
  const AudioVisualizer({super.key});

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> {
  final FlutterFft _flutterFft = FlutterFft();
  List<double> _magnitudes = List.filled(64, 0);

  @override
  void initState() {
    super.initState();
    _initMic();
  }

  Future<void> _initMic() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      await _flutterFft.startRecorder();
      _flutterFft.onRecorderStateChanged.listen((data) {
        if (data != null && data['fft'] != null) {
          final fftData = List<double>.from(data['fft']);
          setState(() {
            _magnitudes = fftData.take(64).toList();
          });
        }
      });
    } else {
      debugPrint('Microphone permission denied');
    }
  }

  @override
  void dispose() {
    _flutterFft.stopRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter: BarVisualizer(_magnitudes),
        ),
      ),
    );
  }
}

class BarVisualizer extends CustomPainter {
  final List<double> magnitudes;
  final Paint barPaint = Paint()..color = Colors.greenAccent;

  BarVisualizer(this.magnitudes);

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (magnitudes.length * 1.5);
    final maxHeight = size.height * 0.8;

    for (int i = 0; i < magnitudes.length; i++) {
      final mag = magnitudes[i].clamp(0, 1000);
      final height = (mag / 1000) * maxHeight;
      final x = i * barWidth * 1.5;
      final y = size.height - height;

      final rect = Rect.fromLTWH(x, y, barWidth, height);
      canvas.drawRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
