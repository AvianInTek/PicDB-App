import 'package:flutter/material.dart';

class InfoBar extends StatelessWidget {
  final int activeIndex;
  final int totalIndex;

  const InfoBar({super.key, required this.totalIndex, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalIndex, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Container(
            width: 30,
            height: 10,
            decoration: BoxDecoration(
              color: index == activeIndex ? Colors.green : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }
}
