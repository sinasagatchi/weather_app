import 'package:flutter/material.dart';

import '../../config/fonts/custom_icons_icons.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Stack(
      alignment: Alignment.center,
      children: [
        _Circle(height: 40, color: color),
        _Circle(height: 30, color: color),
        Icon(
          CustomIcons.applogo,
          color: color,
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final double height;
  final Color color;
  const _Circle({
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: height,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 1.5,
        ),
      ),
    );
  }
}
