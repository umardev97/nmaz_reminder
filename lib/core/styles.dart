import 'package:flutter/material.dart';

class AppShadows {
  static const soft = [
    BoxShadow(
      color: Color(0x120F0D0A),
      blurRadius: 28,
      offset: Offset(0, 10),
    ),
  ];
}

class AppGradients {
  static const premium = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF29241E), Color(0xFF151310)],
  );

  static const gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE4BF68), Color(0xFFAA711C)],
  );
}
