import 'package:flutter/material.dart';

class InfoBar extends StatelessWidget {
  final int totalIndex;
  final int activeIndex;

  const InfoBar({super.key, required this.totalIndex, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalIndex,
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: index == activeIndex ? Colors.black : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
