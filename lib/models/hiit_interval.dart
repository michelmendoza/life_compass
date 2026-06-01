import 'package:flutter/material.dart';

class HiitInterval {
  final String name;
  final Duration duration;
  final Color color;
  final String icon;

  const HiitInterval({
    required this.name,
    required this.duration,
    required this.color,
    this.icon = '💪',
  });
}
