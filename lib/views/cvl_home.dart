import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:seekaclimb/views/cvl_odin.dart';
import 'package:seekaclimb/views/cvl_route_editor.dart';
import 'package:seekaclimb/map_demo.dart';

class CvlHome extends StatefulWidget {
  const CvlHome({super.key});

  @override
  State<CvlHome> createState() => _CvlHomeState();
}

class _CvlHomeState extends State<CvlHome> {
  final CwMapController _mapController = CwMapController();
  final LocationService _locationService = LocationService();
  void _onLocationButtonPressed() async {
    try {
      await _locationService.initialize();
      if (!mounted) return;

      // Obtenir la position actuelle
      final userLocation = await _locationService.getCurrentPosition();
      if (!mounted) return;

      if (userLocation != null) {
        _mapController.animateToLocation(userLocation, zoom: 15.0);
      } else {
        context.showWarning(
          'Position indisponible',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (!mounted) return;
      context.showError('Erreur lors de l\'obtention de la position');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CwMap(
        controller: _mapController,
        locationService: _locationService,
        showUserLocation: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onLocationButtonPressed,
        child: Icon(Icons.near_me_rounded),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              context.pushPage(CvlOdin());
              break;
            case 1:
              context.pushPage(CvlRouteEditor());
              break;
            case 2:
              context.pushPage(MapExamplePage());
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Edit Route',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        ],
      ),
    );
  }
}
