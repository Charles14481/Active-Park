import 'dart:async';

import 'package:active_park/src/markers.dart';
import 'package:active_park/src/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

/// Page with Google Maps API to find nearby spots
class FindPage extends StatefulWidget {
  const FindPage({super.key});

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  // You can change these
  final int mapN = 5;
  double mapMaxDist = 1;

  late GoogleMapController mapController;
  final TextEditingController destController = TextEditingController();
  bool _spotsGenerated = false;
  bool _locationRequested = false;
  ParkSpot? _selectedSpot;

  @override
  void initState() {
    super.initState();
    // Request location when FindPage is opened
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final UserModel user = context.read<UserModel>();
      if (!user.posUpdated && !_locationRequested) {
        _locationRequested = true;
        await user.initLocation();
        setState(() {}); // Trigger rebuild after location is set
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    final UserModel user = context.watch<UserModel>();
    final MapModel map = context.watch<MapModel>();

    // Wait for user location to be available
    if (!user.posUpdated) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Getting device location...')
          ],
        ),
      );
    }

    // Generate spots only once
    if (!_spotsGenerated) {
      _spotsGenerated = true;
      unawaited(map.generateRandom(mapN, mapMaxDist, GoogleRoutesService(), user.pos));
    }

    // Show map or loading spinner
    return Consumer<MapModel>(
      builder: (final BuildContext context, final MapModel map, final Widget? child) {
        if (map.spots.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Generating spots...')
              ],
            ),
          );
        }
        return Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: (final GoogleMapController controller) => mapController = controller,
              initialCameraPosition: CameraPosition(
                target: user.pos,
                zoom: 14,
              ),
              markers: <Marker>{
                for (final ParkSpot spot in map.spots)
                  if (spot.time != null)
                    Marker(
                      markerId: MarkerId(spot.loc.toString()),
                      position: spot.loc,
                      onTap: () {
                        setState(() {
                          // _selectedMarker = spot.loc;
                          _selectedSpot = spot;
                        });
                      },
                    )
              },
            ),
            // Display menu about marker
            if (_selectedSpot != null)
              Positioned(
                left: 20,
                right: 20,
                bottom: 50,
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(_selectedSpot!.type, style: Theme.of(context).textTheme.titleMedium),
                        Text('Hourly Rate: ${_selectedSpot!.info[1]}\$/hr'),
                        Text('Time: ${_selectedSpot!.info[2]} minutes'),
                        Text('Details: ${_selectedSpot!.info[3]}'),
                        Text('Estimated driving time: ${_selectedSpot!.time! ~/ 60} minutes'),
                        const SizedBox(height: 8),
                        if (_selectedSpot!.type == 'Your post')
                          ElevatedButton(
                            onPressed: () {
                              map.removeSpot(_selectedSpot!.index!);
                              setState(() {
                                _selectedSpot = null;
                              });
                            },
                            child: const Text('Delete Post'),
                          )
                        else
                          ElevatedButton(
                            onPressed: () async {
                              final bool? reserved = await showModalBottomSheet<bool>(
                                context: context,
                                builder: (final BuildContext context) => ReserveSpotSheet(spot: _selectedSpot!, user: user, map: map),
                              );
                              if (reserved ?? false) {
                                setState(() {
                                  _selectedSpot = null;
                                });
                              }
                            },
                            child: const Text('Reserve Spot'),
                          ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedSpot = null;
                            });
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      }
    );
  }
}

/// Popup with confirmation to reserve spot
class ReserveSpotSheet extends StatelessWidget {
  const ReserveSpotSheet({required this.spot, required this.user, required this.map, super.key});
  final ParkSpot spot;
  final UserModel user;
  final MapModel map;

  @override
  Widget build(final BuildContext context) => Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Reserve this spot?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(spot.type),
            Text('Rate: ${spot.info[1]}\$/hr'),
            Text('Time: ${spot.info[2]} minutes'),
            Text('Details: ${spot.info[3]}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                user.makeReservation(spot, 15);
                map.removeSpot(spot.index!);
                Navigator.pop(context, true);
              },
              child: const Text('Confirm Reservation'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
}
