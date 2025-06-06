import 'package:flutter/material.dart';

class CwRoutePointToolbar extends StatelessWidget {
  final Color selectedColor;
  final double selectedWidth;
  final Function(Color) onColorChanged;
  final Function(double) onWidthChanged;

  const CwRoutePointToolbar({
    super.key,
    required this.selectedColor,
    required this.selectedWidth,
    required this.onColorChanged,
    required this.onWidthChanged,
  });
  static const List<Color> _predefinedColors = [
    Colors.yellow,
    Colors.orange,
    Colors.blue,
    Colors.red,
    Colors.black,
    Colors.white,
    Colors.green,
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          const Text(
            'Options du tracé',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Section couleurs
          Row(
            children: [
              const Text(
                'Couleur',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: Row(
                    children: _predefinedColors.asMap().entries.map((entry) {
                      final index = entry.key;
                      final color = entry.value;
                      final isSelected = color == selectedColor;
                      final isLastItem = index == _predefinedColors.length - 1;

                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: isLastItem ? 0 : 6),
                          child: GestureDetector(
                            onTap: () => onColorChanged(color),
                            child: Container(
                              height: 28,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Section épaisseur
          Row(
            children: [
              const Text(
                'Épaisseur',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Text(
                '${selectedWidth.toInt()}px',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: Colors.blue,
                    overlayColor: Colors.blue.withValues(alpha: 0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: selectedWidth,
                    min: 1.0,
                    max: 15.0,
                    divisions: 14,
                    onChanged: onWidthChanged,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
