import 'package:flutter/material.dart';

class CurrencyPage extends StatelessWidget {
  const CurrencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Konversi Mata Uang',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
