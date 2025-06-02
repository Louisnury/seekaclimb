import 'package:flutter/material.dart';
import 'package:seekaclimb/enums/e_hold_type.dart';

class CwHoldTypeToolbar extends StatefulWidget {
  final List<EHoldType> selectedHoldTypes;
  final Function(EHoldType) onHoldTypeToggled;

  const CwHoldTypeToolbar({
    super.key,
    required this.selectedHoldTypes,
    required this.onHoldTypeToggled,
  });

  @override
  State<CwHoldTypeToolbar> createState() => _CwHoldTypeToolbarState();
}

class _CwHoldTypeToolbarState extends State<CwHoldTypeToolbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14.0),
      height: 85,
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 10.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20.0,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              EHoldType.start,
              'Départ',
              Icons.play_arrow_rounded,
              const Color(0xFF22C55E),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildToggleButton(
              EHoldType.foot,
              'Pied',
              Icons.directions_walk_rounded,
              const Color(0xFFEAB308),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildToggleButton(
              EHoldType.end,
              'Fin',
              Icons.flag_rounded,
              const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildToggleButton(
              EHoldType.crux,
              'Crux',
              Icons.warning_amber_rounded,
              const Color(0xFF7745CE),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    EHoldType holdType,
    String label,
    IconData icon,
    Color color,
  ) {
    final bool isSelected = widget.selectedHoldTypes.contains(holdType);

    return GestureDetector(
      onTap: () => widget.onHoldTypeToggled(holdType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey('$holdType-$isSelected'),
                color: isSelected
                    ? Colors.white
                    : color.withValues(alpha: 0.65),
                size: 27,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : color.withValues(alpha: 0.75),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
