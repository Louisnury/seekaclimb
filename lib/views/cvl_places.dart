import 'dart:async';
import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:seekaclimb/models/cml_place.dart';
import 'package:seekaclimb/models/cml_wall.dart';
import 'package:seekaclimb/providers/cpl_place.dart';
import 'package:seekaclimb/providers/cpl_route.dart';
import 'package:seekaclimb/providers/cpl_wall.dart';
import 'package:seekaclimb/views/cvl_route_editor.dart';

class CvlPlaces extends StatefulWidget {
  const CvlPlaces({super.key});

  @override
  State<CvlPlaces> createState() => _CvlPlacesState();
}

class _CvlPlacesState extends State<CvlPlaces> {
  final CplPlace _placeProvider = CplPlace();
  final CplRoute _routeProvider = CplRoute();
  final Map<int, CplWall> _wallProviders = {};
  final Map<int, Future<void>?> _wallLoadingFutures = {};
  late CmlPlace? _currentPlace;
  late CmlWall? _currentWall;

  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _isSearching = ValueNotifier(false);
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  final ValueNotifier<int> _expandedPlaceId = ValueNotifier(-1);
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _isSearching.dispose();
    _searchQuery.dispose();
    _expandedPlaceId.dispose();
    _debounceTimer?.cancel();

    // Nettoyer les providers de murs
    for (final provider in _wallProviders.values) {
      provider.dispose();
    }
    _wallProviders.clear();
    _wallLoadingFutures.clear();

    super.dispose();
  }

  void _onPlaceSelected(CmlPlace place, CmlWall? wall) {
    if (place != _currentPlace) {
      context.modelUpdate<CmlPlace?>("currentPlace", place);
    }

    if (wall != _currentWall) {
      context.modelUpdate<CmlWall?>("currentWall", wall);
    }

    // Fermer le drawer
    context.pop();
  }

  void _togglePlaceExpansion(int placeId) {
    _expandedPlaceId.value = _expandedPlaceId.value == placeId ? -1 : placeId;
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _isSearching.value = query.isNotEmpty;

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _searchQuery.value = query;
      }
    });
  }

  CplWall _getWallProvider(int placeId) {
    if (!_wallProviders.containsKey(placeId)) {
      _wallProviders[placeId] = CplWall();

      // Nettoyer les anciens providers si on en a trop
      if (_wallProviders.length > 10) {
        final oldestKey = _wallProviders.keys.first;
        _wallProviders[oldestKey]?.dispose();
        _wallProviders.remove(oldestKey);
        _wallLoadingFutures.remove(oldestKey);
      }
    }

    return _wallProviders[placeId]!;
  }

  Future<void>? _getWallLoadingFuture(int placeId) {
    if (!_wallLoadingFutures.containsKey(placeId)) {
      final wallProvider = _getWallProvider(placeId);
      _wallLoadingFutures[placeId] = wallProvider.loadData();
    }

    return _wallLoadingFutures[placeId];
  }

  @override
  Widget build(BuildContext context) {
    _currentPlace = context.modelTryGet<CmlPlace>("currentPlace");
    _currentWall = context.modelTryGet("currentWall");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentPlace != null
              ? (_currentWall != null
                    ? "${_currentPlace!.name} - ${_currentWall!.name}"
                    : _currentPlace!.name)
              : "Tous les lieux",
        ),
      ),

      drawer: _buildPlaceSearchDrawer(),
      body: InfiniteScrollList(
        provider: _routeProvider,
        queryParams: {
          if (_currentPlace != null) 'place_id': _currentPlace?.id.toString(),
        },
        itemBuilder: (context, route) {
          return ListTile(
            title: Text(route.name),
            subtitle: Text(route.description ?? 'No description available'),
            onTap: () async {
              CmlWall? wall;
              try {
                CplWall wallProvider = CplWall();

                await wallProvider.loadData(queryParams: {'id': route.wallId});

                if (wallProvider.items.isEmpty) {
                  throw Exception('Wall not found');
                }

                wall = wallProvider.items.first;
              } catch (e) {
                // Afficher une erreur si le mur n'est pas trouvé
                if (context.mounted) {
                  context.showError(
                    'Impossible de charger le mur associé à la route',
                  );
                }
                return;
              }

              if (context.mounted) {
                context.pushPage(CvlRouteEditor(wall: wall, route: route));
              }
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
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 16),
                // Champ de recherche
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nom du lieu...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: ValueListenableBuilder(
                      valueListenable: _isSearching,
                      builder: (context, isSearching, child) {
                        return _isSearching.value
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _isSearching.value = false;
                                  _searchQuery.value = '';
                                },
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Option pour afficher tous les lieux
          ListTile(
            leading: const Icon(Icons.all_inclusive),
            title: const Text('Tous les lieux'),
            selected: _currentPlace == null,
            onTap: () {
              context.modelUpdate<CmlPlace?>("currentPlace", null);
              context.modelUpdate<CmlWall?>("currentWall", null);
              context.pop();
            },
          ),
          const Divider(),

          // Liste des lieux
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _searchQuery,
              builder: (context, searchQuery, child) {
                return InfiniteScrollList<CmlPlace>(
                  key: ValueKey(searchQuery),
                  provider: _placeProvider,
                  queryParams: {'q': searchQuery},
                  itemBuilder: (context, place) {
                    final isSelected = _currentPlace?.id == place.id;
                    final wallProvider = _getWallProvider(place.id);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _expandedPlaceId,
                          builder: (context, expandedPlaceId, child) {
                            final isExpanded = expandedPlaceId == place.id;

                            return ListTile(
                              leading: Icon(
                                Icons.location_on,
                                color: isSelected && _currentWall == null
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
                              title: Text(
                                place.name,
                                style: TextStyle(
                                  fontWeight: isSelected && _currentWall == null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected && _currentWall == null
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ),
                              ),
                              trailing: FutureBuilder(
                                future: _getWallLoadingFuture(place.id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    );
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    final bool isEmpty =
                                        wallProvider.items.isEmpty;
                                    if (isEmpty) return const SizedBox.shrink();

                                    return IconButton(
                                      icon: Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                      ),
                                      onPressed: () =>
                                          _togglePlaceExpansion(place.id),
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),
                              selected: isSelected && _currentWall == null,
                              onTap: () => _onPlaceSelected(place, null),
                            );
                          },
                        ),

                        // Affichage des murs si le lieu est étendu
                        ValueListenableBuilder(
                          valueListenable: _expandedPlaceId,
                          builder: (context, expandedPlaceId, child) {
                            final bool isExpanded = expandedPlaceId == place.id;

                            if (isExpanded) {
                              return Container(
                                padding: const EdgeInsets.only(left: 32),
                                constraints: const BoxConstraints(
                                  maxHeight: 250,
                                ),
                                child: InfiniteScrollList<CmlWall>(
                                  key: ValueKey('walls_${place.id}'),
                                  provider: wallProvider,
                                  queryParams: {
                                    'place_id': place.id.toString(),
                                  },
                                  itemBuilder: (context, wall) {
                                    final isWallSelected =
                                        _currentWall?.id == wall.id;
                                    return ListTile(
                                      leading: Icon(
                                        Icons.texture,
                                        color: isWallSelected
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                      title: Text(
                                        wall.name,
                                        style: TextStyle(
                                          fontWeight: isWallSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isWallSelected
                                              ? Theme.of(context).primaryColor
                                              : null,
                                          fontSize: 14,
                                        ),
                                      ),
                                      selected: isWallSelected,
                                      onTap: () =>
                                          _onPlaceSelected(place, wall),
                                    );
                                  },
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
