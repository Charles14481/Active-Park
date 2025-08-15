import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

// Start with some randomly generated spots and have ability to add more
// In final implementation there would be a connection to a backend like Firebase

/// Generate and manage spots in app state
class MapModel extends ChangeNotifier {
  final List<ParkSpot> _spots = <ParkSpot>[];
  int _count = 0; // Keep track of markers after deletions

  List<ParkSpot> get spots => _spots;
  int get count => _count;

  /// Generates n random parking spots uniformly distributed in distance up to maxDist (km)
  Future<void> generateRandom(final int n, final double maxD, final GoogleRoutesService grs, final LatLng userPos) async {
    if (kDebugMode) {
      print('Generating positions for ${userPos.latitude}, ${userPos.longitude}');
    }
    final Random random = Random();
    final double maxDist = maxD/111.0;

    for (int i=0; i<n; i++, _count++) {
      final double th = random.nextDouble()*2*pi;
      final double len = random.nextDouble()*maxDist;
      _spots.add(await ParkSpot().initialize(
        LatLng(
          userPos.latitude + len * sin(th),
          userPos.longitude + len * cos(th)), 
          grs, 
          userPos, 
          <String>['roadside', (random.nextInt(3)+4).toString(), (random.nextInt(12)+2).toString(), 'No add. info provided'],
          _count
        )
      );
      if (kDebugMode) {
        print('[$i]: Generated spot: location ${_spots.last.loc.latitude}, ${_spots.last.loc.latitude},\t time ${_spots.last.time}');
      }
    }
    notifyListeners();
  }

  void addSpot(final ParkSpot ps) {
    _spots.add(ps);
    _count++;
    notifyListeners();
  }

  /// Remove ParkSpot whose index at creation = i
  void removeSpot(final int i) {
    final int removeI = _spots.indexWhere((final ParkSpot ps) => ps._index == i);
    _spots.removeAt(removeI);
    notifyListeners();
  }
}


/// Class encapsulating info for one parking spot
class ParkSpot {
  ParkSpot();
  late LatLng _loc;
  late int? _time;
  late int? _index;
  late List<String> _info;

  LatLng get loc => _loc;
  int? get time => _time;
  List<String> get info => _info;
  String get type => _info[0];
  int? get index => _index;

  //info structure: name, cost, time, info
  Future<ParkSpot> initialize(final LatLng loc, final GoogleRoutesService grs, final LatLng userPos, final List<String> info, final int index) async {
    _loc = loc;
    _info = info;
    _index = index;
    if (kDebugMode) {
      print('PS user position ${userPos.latitude}, ${userPos.longitude}');
    }
    _time = await grs.getDrivingTime(startLat: userPos.latitude, startLng: userPos.longitude, endLat: loc.latitude, endLng: loc.longitude, index: index);
    return this;
  }
}


/// Helper class for calling Google Cloud Routes API
class GoogleRoutesService {
  GoogleRoutesService();

  Future<int?> getDrivingTime ({
    required final double startLat,
    required final double startLng,
    required final double endLat,
    required final double endLng,
    required final int index,
  }) async {
    final String data = await rootBundle.loadString('lib/config/secrets.json');
    final Map<String, dynamic> secrets = json.decode(data) as Map<String, dynamic>;
    final String apiKey = secrets['google_maps'] as String;

    final double startLat0 = startLat;
    final double startLng0 = startLng;
    final double endLat0 = endLat;
    final double endLng0 = endLng;

    if (kDebugMode) {
      print('Generating time for [$index]: $startLat0, $startLng0, $endLat0, $endLng0');
    }
    
    final Uri uri = Uri.parse (
      'https://routes.googleapis.com/directions/v2:computeRoutes'
    );

    final Map<String, Object> body = <String, Object>{
      'origin': <String, Map<String, Map<String, double>>>{
        'location': <String, Map<String, double>>{
          'latLng': <String, double>{'latitude': startLat0, 'longitude': startLng0}
        }
      },
      'destination': <String, Map<String, Map<String, double>>>{
        'location': <String, Map<String, double>>{
          'latLng': <String, double>{'latitude': endLat0, 'longitude': endLng0}
        }
      },
      'travelMode': 'DRIVE',
      'routingPreference': 'TRAFFIC_AWARE',
      'computeAlternativeRoutes': false,
      'routeModifiers': <String, bool>{
        'avoidTolls': false,
        'avoidHighways': false,
        'avoidFerries': false
      },
      'languageCode': 'en-US',
      'units': 'METRIC'
    };

    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
    };

    final http.Response response = await http.post(uri, headers: headers, body: jsonEncode(body));
      
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> routes = data['routes'] as List<dynamic>;
      if (routes.isNotEmpty &&
          routes[0] != null &&
          (routes[0] as Map<String, dynamic>).isNotEmpty) {
        final String duration = (routes[0] as Map<String, dynamic>)['duration'] as String;
        return int.parse(duration.replaceAll('s', '')); // in seconds
      }
      else {
        if (kDebugMode) {
          print('For [$index] Could not generate route time, pos: $startLat0, $startLng0, $endLat0, $endLng0');
        }
        if (kDebugMode) {
          print('${response.statusCode}');
        }
        if (kDebugMode) {
          print(response.body);
        }
      }
    }

    return null;
  }
}

Future<String> loadApiKey () async {
  final String data = await rootBundle.loadString('lib/config/secrets.json');
  final Map<String, dynamic> jsonResult = json.decode(data) as Map<String, dynamic>;
  return jsonResult['google_maps'] as String;
}

Future<String> addressOrLatLng (final LatLng position) async {
  try {
    final List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      final Placemark place = placemarks.first;
      return '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
    }
    return position.toString();
  } catch (e) {
    if (kDebugMode) {
      print('Error getting address from LatLng: $e');
    }
    return 'Error: $e';
  }
}
