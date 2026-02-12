import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData iconData;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      style: IconButton.styleFrom(backgroundColor: Colors.white24),
      icon: Icon(
        iconData,
        size: 48,
        color: Colors.white, //
      ),
    );
  }
}
