import 'package:flutter/material.dart';

import '../services/first_run.dart';
import 'auth_gate.dart';
import 'welcome_screen.dart';

/// The welcome on the first start of a phone, then the app as usual.
class StartGate extends StatefulWidget {
  const StartGate({super.key, required this.welcome});

  /// Read before the app starts, so the first frame is already the right one.
  final bool welcome;

  @override
  State<StartGate> createState() => _StartGateState();
}

class _StartGateState extends State<StartGate> {
  late bool _welcome = widget.welcome;

  void _finish() {
    markWelcomed();
    setState(() => _welcome = false);
  }

  @override
  Widget build(BuildContext context) =>
      _welcome ? WelcomeScreen(onDone: _finish) : const AuthGate();
}
