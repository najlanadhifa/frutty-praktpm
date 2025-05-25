import 'package:flutter/material.dart';

class TimePage extends StatelessWidget {
  const TimePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Konversi Zona Waktu',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
