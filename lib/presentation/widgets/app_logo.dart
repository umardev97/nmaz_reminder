import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 90, this.compact = false});

  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Nmaz Reminder',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 14 : 22),
        child: ColoredBox(
          color: const Color(0xFF151310),
          child: SizedBox(
            height: height,
            width: compact ? height : double.infinity,
            child: Image.asset(
              'assets/images/nmaz_reminder.jpeg',
              fit: compact ? BoxFit.cover : BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }
}
