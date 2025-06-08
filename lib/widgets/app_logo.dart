import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppLogo({
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_baru.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback jika logo tidak ditemukan
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.shopping_bag,
            size: (width != null && height != null) 
                ? (width! < height! ? width! * 0.6 : height! * 0.6)
                : 40,
            color: Colors.lightBlue,
          ),
        );
      },
    );
  }
}
