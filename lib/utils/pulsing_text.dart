import 'package:flutter/material.dart';

import 'package:ihealth_naija_test_version/utils/pulsing_text_state.dart';

class PulsingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const PulsingText({
    required this.text,
    required this.style,
  });

  @override
  PulsingTextState createState() => PulsingTextState();
}
