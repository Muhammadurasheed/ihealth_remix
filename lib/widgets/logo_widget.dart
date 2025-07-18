import 'package:flutter/material.dart';
import '../config/theme.dart';

class LogoWidget extends StatelessWidget {
  final LogoSize size;
  final bool animated;

  const LogoWidget({
    Key? key,
    this.size = LogoSize.medium,
    this.animated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double iconSize = size == LogoSize.small 
        ? 16.0 
        : size == LogoSize.large 
            ? 24.0 
            : 20.0;
            
    final double fontSize = size == LogoSize.small 
        ? 18.0 
        : size == LogoSize.large 
            ? 28.0 
            : 22.0;

    if (animated) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0.0, 10.0 * (1.0 - value)),
              child: _buildLogo(iconSize, fontSize),
            ),
          );
        },
      );
    }

    return _buildLogo(iconSize, fontSize);
  }

  Widget _buildLogo(double iconSize, double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.home,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: AppTheme.primaryColor,
            ),
            children: const [
              TextSpan(text: 'iHealth'),
              TextSpan(
                text: 'Naija',
                style: TextStyle(color: AppTheme.accentColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum LogoSize { small, medium, large }