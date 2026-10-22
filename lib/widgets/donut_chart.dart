import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutSegment {
  final String label;
  final double value;
  final Color color;

  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

class DonutChart extends StatefulWidget {
  final List<DonutSegment> segments;
  final double totalValue;
  final String centerTitle;
  final String centerSubtitle;
  final double strokeWidth;
  final double size;

  const DonutChart({
    super.key,
    required this.segments,
    required this.totalValue,
    required this.centerTitle,
    required this.centerSubtitle,
    this.strokeWidth = 32.0,
    this.size = 220.0,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalValue != widget.totalValue ||
        oldWidget.segments.length != widget.segments.length) {
      _controller.reset();
      _controller.forward();
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
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _DonutChartPainter(
                  segments: widget.segments,
                  totalValue: widget.totalValue,
                  progress: _animation.value,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.centerTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.centerSubtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double totalValue;
  final double progress;
  final double strokeWidth;

  _DonutChartPainter({
    required this.segments,
    required this.totalValue,
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    if (totalValue <= 0 || segments.isEmpty) {
      return;
    }

    double startAngle = -math.pi / 2;
    const double gapAngle = 0.04; // small gap between slices for clean modern look

    for (final seg in segments) {
      if (seg.value <= 0) continue;

      final sweepAngle = (seg.value / totalValue) * (2 * math.pi) * progress;
      final adjustedSweep = math.max(0.0, sweepAngle - gapAngle);

      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (gapAngle / 2),
        adjustedSweep,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.totalValue != totalValue ||
        oldDelegate.segments != segments;
  }
}
