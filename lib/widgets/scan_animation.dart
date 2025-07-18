import 'package:flutter/material.dart';
import '../config/theme.dart';

class ScanAnimationWidget extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final String? label;

  const ScanAnimationWidget({
    super.key,
    this.size = 200.0,
    this.color = AppTheme.primaryColor,
    this.duration = const Duration(seconds: 1),
    this.label,
  });

  @override
  State<ScanAnimationWidget> createState() => _ScanAnimationWidgetState();
}

class _ScanAnimationWidgetState extends State<ScanAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse circles
              ...List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final delay = index * 0.3;
                    final opacity = (1.0 - ((_animation.value + delay) % 1)) * 0.7;
                    final scale = 0.5 + ((_animation.value + delay) % 1) * 0.5;
                    
                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: widget.size,
                          height: widget.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.color,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
              
              // Scanning line
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Positioned(
                    top: _animation.value * widget.size,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2.0,
                      color: widget.color.withOpacity(0.7),
                    ),
                  );
                },
              ),
              
              // Center icon
              Container(
                width: widget.size * 0.2,
                height: widget.size * 0.2,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.label!,
            style: TextStyle(
              color: widget.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}