import 'dart:async';
import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:seekaclimb/models/cml_place.dart';
import 'package:seekaclimb/providers/cpl_place.dart';
import 'package:seekaclimb/views/cvl_place.dart';
import 'package:seekaclimb/widgets/cw_place_marker_widget.dart';

class CvlHome extends StatefulWidget {
  const CvlHome({super.key});

  @override
  State<CvlHome> createState() => _CvlHomeState();
}

class _CvlHomeState extends State<CvlHome> {
  final CwMapController _mapController = CwMapController();
  final LocationService _locationService = LocationService();
  final CplPlace _placeProvider = CplPlace();

  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  Timer? _debounceTimer;

  // Cache pour éviter de reconstruire les marqueurs à chaque build
  List<Marker>? _cachedMarkers;
  List<CmlPlace>? _lastPlacesList;

  @override
  void initState() {
    super.initState();
    // Charger tous les lieux au démarrage
    _loadAllPlaces();
  }

  /// Charge tous les lieux en récupérant toutes les pages
  Future<void> _loadAllPlaces() async {
    await _placeProvider.loadData();

    // Continuer à charger les pages suivantes tant qu'il y en a
    while (_placeProvider.hasMoreData &&
        _placeProvider.status != ProviderStatus.error) {
      try {
        await _placeProvider.loadMore();
      } catch (e) {
        break;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQuery.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      _searchQuery.value = query;
    });
  }

  void _onLocationButtonPressed() async {
    try {
      // Utiliser d'abord la position en cache si disponible
      LatLng? userLocation = _locationService.currentLocation;

      if (userLocation != null) {
        _mapController.animateToLocation(userLocation, zoom: 18.0);
        return;
      }

      // Si pas de position en cache, initialiser et obtenir la position
      final bool isInitialized = await _locationService.initialize();
      if (!mounted) return;

      if (isInitialized) {
        userLocation = await _locationService.getCurrentPosition();
        if (!mounted) return;

        if (userLocation != null) {
          _mapController.animateToLocation(userLocation, zoom: 18.0);
        } else {
          context.showWarning(
            'Position indisponible',
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        context.showWarning(
          'Géolocalisation non disponible',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (!mounted) return;
      context.showError('Erreur lors de l\'obtention de la position');
    }
  }

  List<Marker> _buildPlaceMarkers() {
    final currentPlaces = _placeProvider.items;

    // Utiliser le cache si la liste des lieux n'a pas changé
    if (_cachedMarkers != null &&
        _lastPlacesList != null &&
        _lastPlacesList!.length == currentPlaces.length &&
        _listEquals(_lastPlacesList!, currentPlaces)) {
      return _cachedMarkers!;
    }

    // Reconstruire les marqueurs
    _cachedMarkers = currentPlaces.map((place) {
      return Marker(
        point: place.location,
        width: 40.0,
        height: 40.0,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => context.pushPage(CvlPlace(place: place)),
          child: const CwPlaceMarkerWidget(),
        ),
      );
    }).toList();

    _lastPlacesList = List.from(currentPlaces);
    return _cachedMarkers!;
  }

  bool _listEquals(List<CmlPlace> list1, List<CmlPlace> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListenableBuilder(
            listenable: _placeProvider,
            builder: (context, child) {
              return CwMap(
                controller: _mapController,
                locationService: _locationService,
                showUserLocation: true,
                followUserLocation: false,
                markers: _buildPlaceMarkers(),
              );
            },
          ),

          // Barre de recherche en haut
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un lieu...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ValueListenableBuilder<String>(
                  valueListenable: _searchQuery,
                  builder: (context, query, child) {
                    if (query.isEmpty) return const SizedBox.shrink();

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InfiniteScrollList<CmlPlace>(
                        provider: _placeProvider,
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        queryParams: {'q': query},
                        itemBuilder: (context, item) {
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: Text(item.name),
                            onTap: () {
                              _mapController.animateToLocation(
                                item.location,
                                zoom: 18.0,
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onLocationButtonPressed,
        child: const Icon(Icons.near_me_rounded),
      ),
    );
  }
}
