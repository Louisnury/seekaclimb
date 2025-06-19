import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:seekaclimb/models/cml_place.dart';
import 'package:seekaclimb/widgets/cw_place_marker_widget.dart';

class CvlPlace extends StatefulWidget {
  final CmlPlace place;

  const CvlPlace({super.key, required this.place});

  @override
  State<CvlPlace> createState() => _CvlPlaceState();
}

class _CvlPlaceState extends State<CvlPlace> {
  final MapController _mapController = MapController();
  String? _selectedPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.place.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte
            _buildMapSection(),

            // Informations principales
            _buildInfoSection(),

            // Chemins d'accès
            if (widget.place.accesPath.isNotEmpty) _buildAccessPathsSection(),

            // Parkings
            if (widget.place.parkingLocation.isNotEmpty) _buildParkingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return SizedBox(
      height: 300,
      child: CwMap(
        markers: _buildMarkers(),
        polylines: _buildPolylines(),
        initialCenter: widget.place.location,
        initialZoom: 16,
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Marqueur principal du lieu
    markers.add(
      Marker(
        point: widget.place.location,
        width: 40.0,
        height: 40.0,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => _showPlaceDetails(),
          child: CwPlaceMarkerWidget(),
        ),
      ),
    );

    // Marqueurs de parking
    for (LatLng parking in widget.place.parkingLocation) {
      markers.add(
        Marker(
          point: parking,
          width: 40.0,
          height: 40.0,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.local_parking,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  List<Polyline> _buildPolylines() {
    List<Polyline> polylines = [];

    // Afficher le chemin sélectionné ou tous les chemins
    if (_selectedPath != null &&
        widget.place.accesPath.containsKey(_selectedPath)) {
      polylines.add(
        Polyline(
          points: widget.place.accesPath[_selectedPath]!,
          color: Colors.red,
          strokeWidth: 3.0,
        ),
      );
    } else {
      // Afficher tous les chemins avec des couleurs différentes
      int colorIndex = 0;
      final colors = [Colors.green, Colors.blue, Colors.purple, Colors.orange];

      for (MapEntry<String, List<LatLng>> entry
          in widget.place.accesPath.entries) {
        polylines.add(
          Polyline(
            points: entry.value,
            color: colors[colorIndex % colors.length],
            strokeWidth: 2.0,
          ),
        );
        colorIndex++;
      }
    }

    return polylines;
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom du lieu
          Text(
            widget.place.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Type de lieu
          Row(
            children: [
              Icon(
                widget.place.isIndoor ? Icons.home : Icons.landscape,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                widget.place.isIndoor ? 'Site intérieur' : 'Site extérieur',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Adresse
          if (widget.place.addresse != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.place.addresse!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Coordonnées
          Row(
            children: [
              Icon(Icons.gps_fixed, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                '${widget.place.location.latitude.toStringAsFixed(6)}, ${widget.place.location.longitude.toStringAsFixed(6)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          if (widget.place.description != null) ...[
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.place.description!),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildAccessPathsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chemins d\'accès',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...widget.place.accesPath.entries.map((entry) {
            final isSelected = _selectedPath == entry.key;
            return Card(
              color: isSelected ? Colors.orange.withValues(alpha: 0.1) : null,
              child: ListTile(
                leading: Icon(
                  Icons.route,
                  color: isSelected ? Colors.orange : Colors.grey[600],
                ),
                title: Text(entry.key),
                subtitle: Text('${entry.value.length} points'),
                trailing: isSelected
                    ? const Icon(Icons.visibility, color: Colors.orange)
                    : const Icon(Icons.visibility_off),
                onTap: () => _togglePathVisibility(entry.key),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildParkingSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parking',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...widget.place.parkingLocation.asMap().entries.map((entry) {
            final index = entry.key;
            final parking = entry.value;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.local_parking, color: Colors.blue),
                title: Text('Parking ${index + 1}'),
                subtitle: Text(
                  '${parking.latitude.toStringAsFixed(6)}, ${parking.longitude.toStringAsFixed(6)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.center_focus_strong),
                  onPressed: () => _mapController.move(parking, 17.0),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _togglePathVisibility(String pathName) {
    setState(() {
      if (_selectedPath == pathName) {
        _selectedPath = null; // Masquer le chemin s'il est déjà sélectionné
      } else {
        _selectedPath = pathName; // Afficher le nouveau chemin
      }
    });
  }

  void _showPlaceDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.place.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.place.description != null) ...[
              Text(widget.place.description!),
              const SizedBox(height: 16),
            ],
            Text('Coordonnées:'),
            Text(
              '${widget.place.location.latitude.toStringAsFixed(6)}, ${widget.place.location.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
