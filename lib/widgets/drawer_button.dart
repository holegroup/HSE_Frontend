import 'package:flutter/material.dart';

class CustomDrawerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final bool centerText;

  const CustomDrawerButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
    this.backgroundColor = Colors.black,
    this.centerText = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: centerText
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            const SizedBox(width: 15),
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
