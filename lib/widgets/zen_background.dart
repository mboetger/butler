import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ZenBackground extends StatefulWidget {
  const ZenBackground({super.key});

  @override
  State<ZenBackground> createState() => _ZenBackgroundState();
}

class _ZenBackgroundState extends State<ZenBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0.0;
  ui.FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
      });
    });
    _ticker.start();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/zen_glow.frag',
      );
      setState(() {
        _program = program;
      });
    } catch (e) {
      debugPrint('Failed to load shader: $e');
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null) {
      return Container(color: const Color(0xFF101520)); // Fallback background
    }
    return CustomPaint(
      painter: ZenShaderPainter(program: _program!, time: _time),
      child: const SizedBox.expand(),
    );
  }
}

class ZenShaderPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final double time;

  ZenShaderPainter({required this.program, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Dispose the shader to immediately free native resources
    shader.dispose();
  }

  @override
  bool shouldRepaint(covariant ZenShaderPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
