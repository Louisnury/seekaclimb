import 'package:flutter/material.dart';

class CwRoutePointToolbar extends StatefulWidget {
  final Function(double) onWidthChanged;

  const CwRoutePointToolbar({
    super.key,
    required this.onWidthChanged,
  });

  @override
  State<CwRoutePointToolbar> createState() => _CwRoutePointToolbarState();
}

class _CwRoutePointToolbarState extends State<CwRoutePointToolbar> {
  double _selectedWidth = 2.0;

  double get currentWidth => _selectedWidth;

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
          // Section épaisseur
          Row(
            children: [
              const Text(
                'Épaisseur',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Text(
                '${_selectedWidth.toInt()}px',
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
                    value: _selectedWidth,
                    min: 1.0,
                    max: 15.0,
                    divisions: 14,
                    onChanged: (value) {
                      setState(() {
                        _selectedWidth = value;
                      });
                      widget.onWidthChanged(value);
                    },
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
