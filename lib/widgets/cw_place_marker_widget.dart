import 'package:flutter/material.dart';

class CwPlaceMarkerWidget extends StatelessWidget {
  const CwPlaceMarkerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.terrain, color: Colors.white, size: 20),
    );
  }
}
