import 'package:active_park/src/markers.dart';
import 'package:active_park/src/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Page with basic info 
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(final BuildContext context) {
    final MapModel map = context.watch<MapModel>();
    final UserModel user = context.watch<UserModel>();
    
    const double gap = 35;
    final ThemeData theme = Theme.of(context);
    final TextStyle sizeMed = theme.textTheme.displayMedium!;
    final TextStyle styleMed = theme.textTheme.headlineLarge!.copyWith(
      color: theme.colorScheme.onSecondary,
    );
    final TextStyle styleSmall = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.tertiary,
    );
    final TextStyle sizeSmall = theme.textTheme.bodyLarge!;

    // Only show reserved spot info or default text
    final ParkSpot? reservedSpot = user.reservation;

    return Center(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Spots near you: ',
                style: sizeMed.copyWith(color: theme.colorScheme.primary),
              ),
              Text('${map.spots.length}',
                style: sizeMed.copyWith(color: theme.colorScheme.secondary),
              ),
            ],
          ),
          const SizedBox(height: gap+10),
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (reservedSpot != null) ...<Widget>[
                  Text('Reserved Spot', style: styleMed, textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  FutureBuilder<String>(
                    future: addressOrLatLng(reservedSpot.loc),
                    builder: (final BuildContext context, final AsyncSnapshot<String> snapshot) {
                      if (!snapshot.hasData) {
                        return const Text('Loading address...');
                      }
                      
                      String text;
                      if (snapshot.hasError) {
                        text = 'at ${reservedSpot.loc}';
                      } else {
                        text = 'at ${snapshot.data}';
                      }

                      return Text(
                        text, 
                        textAlign: TextAlign.center,
                        style: sizeSmall.copyWith(color: Colors.teal[400]),
                      );
                    },
                  ),
                  Text('Details: ${reservedSpot.info[3]}',
                    style: sizeSmall.copyWith(color: Colors.teal[700]),
                  ),
                ] else ...<Widget>[
                  Text('No spot yet', style: styleMed),
                  const Text('Reserve one in the find tab'),
                ]
              ],
            ),
          ),
          const SizedBox(height: gap),
          Text('Reserved milestone progress:', style: styleSmall),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.75,
            child:
            (user.nextMilestone(user.taken) != -1)
            ? Column(
              children: <Widget>[
                LinearProgressIndicator(
                    minHeight: 20,
                    value: user.taken / user.nextMilestone(user.taken),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.tertiary),
                    borderRadius: BorderRadiusGeometry.circular(6),
                  ),
                Text('Reserve ${user.nextMilestone(user.taken)-user.taken} more spots for ${user.reward(0, user.nextMilestone(user.taken))} credits')
              ],
            )
            : const Text('Done with milestone!')
          ),
          const SizedBox(height: gap*0.8),
          Text('Posted milestone progress:', style: styleSmall),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.75,
            child:
            (user.nextMilestone(user.given) != -1)
            ? Column(
              children: <Widget>[
                LinearProgressIndicator(
                  minHeight: 20,
                  value: user.given / user.nextMilestone(user.given),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.tertiary),
                  borderRadius: BorderRadius.circular(6),
                ),
                Text('Post ${user.nextMilestone(user.given)-user.given} more spots for ${user.reward(1, user.nextMilestone(user.given))} credits')
              ],
            )
            : const Text('Done with milestone!')
          ),
        ],
      ),
    );
  }
}
