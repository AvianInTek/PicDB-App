import 'package:flutter/material.dart';
import 'package:picdb/models/color_palettes.dart';

class ColorScreen extends StatefulWidget {
  final String selectedColor;
  final Function(String) onSelectColor;

  const ColorScreen({required this.selectedColor, required this.onSelectColor, super.key});

  @override
  _ColorScreenState createState() => _ColorScreenState(selectedColor: selectedColor, onSelectColor: onSelectColor);
}

class _ColorScreenState extends State<ColorScreen> {
  final Function(String) onSelectColor;
  final String selectedColor;

  _ColorScreenState({required this.selectedColor, required this.onSelectColor});
  String _selectedColor = Palette.beige;
  void _onColorSelected(String color) {
    setState(() {
      _selectedColor = color;
      onSelectColor(color);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 160.0,
                  backgroundColor: HexColor.fromHex(_selectedColor).withOpacity(0.2),
                ),
                CircleAvatar(
                  radius: 120.0,
                  backgroundColor: HexColor.fromHex(_selectedColor).withOpacity(0.4),
                ),
                CircleAvatar(
                  radius: 70.0,
                  backgroundColor: HexColor.fromHex(_selectedColor),
                  child: const Icon(
                    Icons.sentiment_very_satisfied,
                    color: Colors.white,
                    size: 100.0,
                  ),
                ),
              ],
            ),
            // Mood Choices
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ColorButton(
                  color: Palette.beige,
                  onTap: () => _onColorSelected(Palette.beige),
                ),
                ColorButton(
                  color: Palette.darkBeige,
                  onTap: () => _onColorSelected(Palette.darkBeige),
                ),
                ColorButton(
                  color: Palette.blue,
                  onTap: () => _onColorSelected(Palette.blue),
                ),
                ColorButton(
                  color: Palette.green,
                  onTap: () => _onColorSelected(Palette.green),
                ),
                ColorButton(
                  color: Palette.peach,
                  onTap: () => _onColorSelected(Palette.peach),
                ),
                ColorButton(
                  color: Palette.purple,
                  onTap: () => _onColorSelected(Palette.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ColorButton extends StatelessWidget {
  final String color;
  final VoidCallback onTap;

  const ColorButton({super.key, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
            radius: 20.0,
            backgroundColor: HexColor.fromHex(color),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white, // Change this to your desired border color
                  width: 2.0,
                ),
              ),
            )
        ),
      ),
    );
  }
}

