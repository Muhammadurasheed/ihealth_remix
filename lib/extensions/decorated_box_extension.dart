import 'package:flutter/material.dart';

extension DecoratedBoxExtension on Container {
  Container copyWith({
    Key? key,
    Widget? child,
    BoxDecoration? decoration,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Clip? clipBehavior,
    Duration? transformDuration,
    Color? color,
    double opacity = 1.0,
  }) {
    return Container(
      key: key ?? this.key,
      child: child ?? this.child,
      decoration: decoration ??
          (this.decoration as BoxDecoration?)?.copyWith(
            color: color != null
                ? color.withOpacity(opacity)
                : (this.decoration as BoxDecoration?)?.color?.withOpacity(opacity),
          ),
      constraints: constraints ?? this.constraints,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      width: width ?? (this.constraints?.maxWidth == double.infinity ? null : this.constraints?.maxWidth),
      height: height ?? (this.constraints?.maxHeight == double.infinity ? null : this.constraints?.maxHeight),
      clipBehavior: clipBehavior ?? this.clipBehavior,
    );
  }
}