import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Exemple d'utilisation du widget CwMap
class MapExamplePage extends StatefulWidget {
  const MapExamplePage({super.key});

  @override
  State<MapExamplePage> createState() => _MapExamplePageState();
}

class _MapExamplePageState extends State<MapExamplePage> {
  final CwMapController _mapController = CwMapController();
  final LocationService _locationService = LocationService();
  bool _showUserLocation = true;
  bool _followUserLocation = false;

  // Exemples de points d'escalade
  final List<LatLng> climbingSites = [
    const LatLng(45.8326, 6.8652), // Chamonix
    const LatLng(45.0452, 6.0633), // Freney
    const LatLng(46.0207, 7.7491), // Zermatt
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte OpenStreetMap - SeekAClimb'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Contrôles de la carte
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _moveToAlps,
                  icon: const Icon(Icons.terrain),
                  label: const Text('Alpes'),
                ),
                ElevatedButton.icon(
                  onPressed: _fitAllMarkers,
                  icon: const Icon(Icons.zoom_out_map),
                  label: const Text('Tout voir'),
                ),
                ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Position'),
                ),
              ],
            ),
          ),
          // Contrôles de géolocalisation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _showUserLocation,
                      onChanged: (value) {
                        setState(() {
                          _showUserLocation = value ?? false;
                        });
                      },
                    ),
                    const Text('Afficher position'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _followUserLocation,
                      onChanged: (value) {
                        setState(() {
                          _followUserLocation = value ?? false;
                        });
                      },
                    ),
                    const Text('Suivre position'),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _centerOnUserLocation,
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text('Ma position'),
                ),
              ],
            ),
          ),
          // Widget de carte
          Expanded(
            child: CwMap(
              controller: _mapController,
              initialCenter: const LatLng(45.8326, 6.8652), // Chamonix
              initialZoom: 10.0,
              minZoom: 4.0,
              maxZoom: 22.0,
              markers: _buildMarkers(),
              polylines: _buildPolylines(),
              onTap: _onMapTap,
              onLongPress: _onMapLongPress,
              onMapEvent: _onMapEvent,
              showUserLocation: _showUserLocation,
              followUserLocation: _followUserLocation,
              locationService: _locationService,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRandomMarker,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add_location, color: Colors.white),
      ),
    );
  }

  /// Construction des marqueurs pour les sites d'escalade
  List<Marker> _buildMarkers() {
    return climbingSites
        .map(
          (site) => MarkerUtils.createClimbingMarker(
            point: site,
            onTap: () => _onClimbingSiteTap(site),
          ),
        )
        .toList();
  }

  /// Construction des polylignes pour les routes
  List<Polyline> _buildPolylines() {
    return [
      RoutePolylineUtils.createRoutePolyline(
        points: [
          const LatLng(45.8326, 6.8652),
          const LatLng(45.8400, 6.8700),
          const LatLng(45.8450, 6.8750),
        ],
        color: Colors.red,
        strokeWidth: 3.0,
      ),
      RoutePolylineUtils.createApproachPolyline(
        points: [
          const LatLng(45.0452, 6.0633),
          const LatLng(45.0500, 6.0680),
        ],
        color: Colors.green,
        strokeWidth: 2.0,
      ),
    ];
  }

  /// Déplace la carte vers les Alpes
  void _moveToAlps() {
    _mapController.moveToLocation(
      const LatLng(45.8326, 6.8652), // Chamonix
      zoom: 12.0,
    );
  }

  /// Ajuste la vue pour voir tous les marqueurs
  void _fitAllMarkers() {
    if (climbingSites.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(climbingSites);
      _mapController.fitBounds(bounds, padding: const EdgeInsets.all(50));
    }
  }

  /// Affiche la position actuelle de la carte
  void _getCurrentLocation() {
    final center = _mapController.getCurrentCenter();
    final zoom = _mapController.getCurrentZoom();

    if (center != null && zoom != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Position: ${center.latitude.toStringAsFixed(4)}, '
            '${center.longitude.toStringAsFixed(4)} - '
            'Zoom: ${zoom.toStringAsFixed(1)}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Ajoute un marqueur aléatoire
  void _addRandomMarker() {
    setState(() {
      // Ajoute un nouveau site d'escalade près de Chamonix
      climbingSites.add(
        LatLng(
          45.8326 +
              (0.1 * (2 * (0.5 - DateTime.now().millisecond / 1000))),
          6.8652 +
              (0.1 * (2 * (0.5 - DateTime.now().microsecond / 1000000))),
        ),
      );
    });
  }

  /// Callback quand on tape sur la carte
  void _onMapTap(LatLng point) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tap: ${point.latitude.toStringAsFixed(6)}, '
          '${point.longitude.toStringAsFixed(6)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Callback quand on fait un appui long sur la carte
  void _onMapLongPress(LatLng point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau site d\'escalade ?'),
        content: Text(
          'Voulez-vous ajouter un site d\'escalade à cette position ?\n'
          'Lat: ${point.latitude.toStringAsFixed(6)}\n'
          'Lng: ${point.longitude.toStringAsFixed(6)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                climbingSites.add(point);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  /// Callback quand on tape sur un site d'escalade
  void _onClimbingSiteTap(LatLng site) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Site d\'escalade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: ${site.latitude.toStringAsFixed(6)}'),
            Text('Longitude: ${site.longitude.toStringAsFixed(6)}'),
            const SizedBox(height: 16),
            const Text('Actions disponibles:'),
            const Text('• Voir les détails'),
            const Text('• Ajouter une route'),
            const Text('• Partager la position'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _moveToSite(site);
            },
            child: const Text('Centrer'),
          ),
        ],
      ),
    );
  }

  /// Centre la carte sur un site spécifique
  void _moveToSite(LatLng site) {
    _mapController.animateToLocation(site, zoom: 15.0);
  }

  /// Centre la carte sur la position de l'utilisateur
  void _centerOnUserLocation() {
    final userLocation = _locationService.currentLocation;
    if (userLocation != null) {
      _mapController.moveToLocation(userLocation, zoom: 15.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Position utilisateur non disponible'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Callback pour les événements de la carte
  void _onMapEvent(MapEvent event) {
    // Vous pouvez logger les événements de la carte ici
    // print('Événement carte: center=${event.camera.center}, zoom=${event.camera.zoom}');
  }
}
