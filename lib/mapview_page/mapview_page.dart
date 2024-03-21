import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({super.key});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  Position? _currentPosition;
  final MapController _mapController = MapController();

  Future<Position?> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permission not granted');
    }
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });

    return _currentPosition;
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location services are disabled. Please enable the services')));
      }
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
        }
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Location")),
      body: SafeArea(
        child: FutureBuilder<Position?>(
            future: _getCurrentPosition(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                    child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                      center: LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                      zoom: 16,
                      minZoom: 16,
                      maxZoom: 18,
                      interactiveFlags:
                          InteractiveFlag.pinchZoom | InteractiveFlag.drag),
                  children: [
                    TileLayer(
                      backgroundColor: Colors.black,
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                            point: LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude),
                            builder: (context) => const Icon(
                                  Icons.location_on,
                                  size: 32,
                                  color: Colors.red,
                                ))
                      ],
                    )
                  ],
                ));
              } else if (snapshot.hasError) {
                debugPrint('Map Error: ' + snapshot.error.toString());
                return const Center(
                  child: Text(
                    'Error loading location',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text("Loading...")
                    ]),
              );
            }),
      ),
    );
  }
}

/* 
Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('LAT: ${_currentPosition?.latitude ?? ""}'),
                      Text('LNG: ${_currentPosition?.longitude ?? ""}'),
                      // Text('ADDRESS: ${_currentAddress ?? ""}'),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _getCurrentPosition,
                        child: const Text("Get Current Location"),
                      )
                    ],
                  ),
*/
