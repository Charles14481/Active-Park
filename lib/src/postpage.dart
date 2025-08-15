import 'package:active_park/src/markers.dart';
import 'package:active_park/src/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

/// Page where user can post spots
class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  PostPageState createState() => PostPageState();
}
class PostPageState extends State<PostPage> {
  final Map<String, TextEditingController> postControllers = <String, TextEditingController>{'location' : TextEditingController(), 'time' : TextEditingController(), 'cost' : TextEditingController(), 'details' : TextEditingController()};
  bool _locationRequested = false;

  @override
  void initState() {
    super.initState();
    // Request location when PostPage is opened
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final UserModel user = context.read<UserModel>();
      if (!user.posUpdated && !_locationRequested) {
        _locationRequested = true;
        await user.initLocation();
        if (context.mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    for (final TextEditingController tec in postControllers.values) {
      tec.dispose();
    }

    super.dispose();
  }
  
  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle styleTitle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.secondary,
    );
    theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.tertiary,
    );
    final TextStyle styleButton = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.primary,
    );
    theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.secondary,
    );

    final UserModel user = context.watch<UserModel>();
    final Future<String> address = addressOrLatLng(user.pos);

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

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width*0.75,
        child: Column(
          spacing: 15,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Post a spot', style: styleTitle),
            const SizedBox(),
            const Text('Input information here:'),
            const SizedBox(height: 10,),
            const Text('Location (only change if wrong or missing):'),
            LocationField(address: address, postControllers: postControllers),
            const SizedBox(),
            TextField(
              controller: postControllers['time'],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('^[0-9]*')),
                LengthLimitingTextInputFormatter(5)],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'minutes until earliest',
              ),
            ),
            const SizedBox(),
            TextField(
              controller: postControllers['cost'],
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^[\d\.]*'))],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: r'cost to park an hour ($)',
              ),
            ),
            const SizedBox(),
            TextField(
              controller: postControllers['details'],
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "specifics about your car's location",
              ),
            ),
            const SizedBox(height: 20,),
            FilledButton(
              onPressed: () async {
                if (!context.mounted) {
                  return;
                }
                final UserModel user = context.read<UserModel>();
                final MapModel map = context.read<MapModel>();
                final String locationText = postControllers['location']!.text.trim();
                final String time = postControllers['time']!.text.trim();
                final String cost = postControllers['cost']!.text.trim();
                final String details = postControllers['details']!.text.trim();

                if (time.isEmpty || cost.isEmpty) {
                  await showPrompt(context, 'Error. Please ensure time and cost are filled.');
                  return;
                }

                LatLng? loc;
                // Try to geocode the location if user changed it, else use user.pos
                if (locationText.isNotEmpty && locationText != await addressOrLatLng(user.pos)) {
                  try {
                    final List<Location> locations = await locationFromAddress(locationText);
                    if (locations.isNotEmpty) {
                      loc = LatLng(locations.first.latitude, locations.first.longitude);
                    }
                  } catch (e) {
                      if (!context.mounted) {
                        return;
                      }
                      await showPrompt(context, 'Could not parse location.');
                      return;
                    }
                } else {
                  loc = user.pos;
                }

                // Try to create a new ParkSpot
                try {
                  final GoogleRoutesService grs = GoogleRoutesService();
                  final ParkSpot spot = await ParkSpot().initialize(loc!, grs, user.pos, <String>['Your post', time, cost, details], map.count);
                  if (!context.mounted) {
                    return;
                  }
                  if (spot.time == null) {
                    await showPrompt(context, 'Could not generate route time.');
                    return;
                  }
                  map.addSpot(spot);
                  user.posted(0);
                  await showPrompt(context, 'Spot posted successfully.', isError: false);
                } catch (e) {
                  if (context.mounted) {
                    await showPrompt(context, 'Could not create a marker.');
                  }
                }
              },
              child: Text('Finish', style: styleButton)
            ),
            const SizedBox(height: 10,),
            const HelpButton(),
          ],
        ),
      ),
    );
  }

  Future<dynamic> showPrompt(final BuildContext context, final String statement, {final bool isError=true}) => showDialog(
      context: context,
      builder: (final BuildContext context) => AlertDialog(
        title: isError? const Text('Error') : const Text('Success'),
        content: Text(statement),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

  // Get text from clipboard
  Future<String> getClipBoardData() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text ?? '';
  }
}

/// Location input with paste and default=current location
class LocationField extends StatelessWidget {
  const LocationField({
    required this.address, required this.postControllers, super.key,
  });

  final Future<String> address;
  final Map<String, TextEditingController> postControllers;

  @override
  Widget build(final BuildContext context) => FutureBuilder<String>(
      future: address,
      builder: (final BuildContext context, final AsyncSnapshot<String> snapshot) {
        if (!snapshot.hasData) {
          // while data is loading:
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Loading location...')
              ],
            ),
          );
        }
        // Data loaded
        return SizedBox(
          height: 48,
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: postControllers['location'],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: snapshot.data,
                    hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.paste),
                onPressed: () async {
                  final ClipboardData? clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                  if (clipboardData != null) {
                    postControllers['location']!.text = clipboardData.text ?? '';
                  }
                },
              ),
            ],
          ),
        );
      }
    );
}

/// Create help dialog
class HelpButton extends StatelessWidget {
  const HelpButton({
    super.key,
  });

  @override
  Widget build(final BuildContext context) => TextButton.icon(
    icon: const Icon(Icons.help, size: 30),
    label: const Text('Help'),
    onPressed:() => showDialog<String>(
      context: context,
      builder: (final BuildContext context) => AlertDialog(
        title: const Text('Help!'),
        content: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: const <TextSpan>[
              TextSpan(text: "Got a parking spot? Post it a few minutes before you get to your car. When they get to the spot, you'll earn some credits that can go into your next reservation.\n\n"),
              TextSpan(text: 'Location:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' The location of your car (default is current device location).\n'),
              TextSpan(text: 'Time:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' Estimate how long until you get to your car.\n'),
              TextSpan(text: 'Cost:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' Default rates for parking space. Free is \$0.\n'),
              TextSpan(text: 'Specifics:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' Give details about where to find your car (floor, side of building, etc.).'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );
}
