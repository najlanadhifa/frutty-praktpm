import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Saran dan Kesan',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
