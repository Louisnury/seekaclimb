import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:seekaclimb/models/cml_circle.dart';
import 'package:seekaclimb/models/cml_place.dart';
import 'package:seekaclimb/models/cml_point.dart';
import 'package:seekaclimb/models/cml_route.dart';
import 'package:seekaclimb/providers/cpl_place.dart';
import 'package:seekaclimb/providers/cpl_route.dart';
import 'package:seekaclimb/views/cvl_route_editor.dart';

class CvlPlace extends StatefulWidget {
  const CvlPlace({super.key});

  @override
  State<CvlPlace> createState() => _CvlPlaceState();
}

class _CvlPlaceState extends State<CvlPlace> {
  final CplPlace _placeProvider = CplPlace();
  late CplRoute _routeProvider;
  late CmlPlace? _currentPlace;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onPlaceSelected(CmlPlace place) {
    _currentPlace = place;
    setState(() {
      _routeProvider = CplRoute(placeId: place.id);
    });

    // Fermer le drawer
    context.pop();

    // Recharger les routes pour ce lieu
    _loadRoutesForPlace(place.id);
  }

  Future<void> _loadRoutesForPlace(int placeId) async {
    // Simuler le chargement des routes pour un lieu spécifique
    // En attendant l'API réelle, on peut filtrer ou recharger les données

    _routeProvider.addItems([
      CmlRoute(
        wallId: placeId,
        name: "Route $placeId-1",
        elements: [
          CmlCircle(point: CmlPoint(x: 200, y: 200), holdTypes: []),
          CmlCircle(point: CmlPoint(x: 200, y: 300), holdTypes: []),
        ],
      ),
      CmlRoute(
        wallId: placeId,
        name: "Route $placeId-2",
        elements: [
          CmlCircle(point: CmlPoint(x: 150, y: 250), holdTypes: []),
          CmlCircle(point: CmlPoint(x: 250, y: 350), holdTypes: []),
        ],
      ),
    ]);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      _placeProvider.searchPlaces(query);
    } else {
      // Recharger tous les lieux
      _placeProvider.loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentPlace = context.modelTryGet<CmlPlace>("currentPlace");
    _routeProvider = CplRoute(placeId: _currentPlace?.id);

    if (_placeProvider.items.isEmpty) {
      _placeProvider.addItems([
        CmlPlace(id: 1, name: "casa", location: LatLng(19.0, 10.0)),
        CmlPlace(
          id: 2,
          name: "dent de la rencune",
          location: LatLng(19.0, 10.0),
        ),
        CmlPlace(id: 3, name: "mont dore", location: LatLng(19.0, 10.0)),
        CmlPlace(id: 4, name: "capucin", location: LatLng(19.0, 10.0)),
        CmlPlace(id: 5, name: "la baladoux", location: LatLng(19.0, 10.0)),
        CmlPlace(id: 6, name: "cournols", location: LatLng(19.0, 10.0)),
      ]);

      _loadRoutesForPlace(0);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentPlace != null ? _currentPlace!.name : "Tous les lieux",
        ),
      ),
      drawer: _buildPlaceSearchDrawer(),
      body: InfiniteScrollList(
        provider: _routeProvider,
        itemBuilder: (context, route) {
          return ListTile(
            title: Text(route.name),
            subtitle: Text(route.description ?? 'No description available'),
            onTap: () {
              context.pushPage(CvlRouteEditor(route: route));
            },
          );
        },
      ),
    );
  }

  Widget _buildPlaceSearchDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Header du drawer
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rechercher un lieu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 16),
                // Champ de recherche
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nom du lieu...',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Option pour afficher tous les lieux
          ListTile(
            leading: Icon(Icons.all_inclusive),
            title: Text('Tous les lieux'),
            selected: _currentPlace == null,
            onTap: () {
              setState(() {
                _currentPlace = null;
                _routeProvider = CplRoute(placeId: 0);
              });
              context.pop();
            },
          ),

          Divider(),

          // Liste des lieux
          Expanded(
            child: InfiniteScrollList<CmlPlace>(
              provider: _placeProvider,
              itemBuilder: (context, place) {
                final isSelected = _currentPlace?.id == place.id;
                return ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                  title: Text(
                    place.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () => _onPlaceSelected(place),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
