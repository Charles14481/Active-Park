
import 'package:active_park/src/usermodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Page with user statistics and shops
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final UserModel user = context.watch<UserModel>();

    const double buttonSpace = 30;

    final ThemeData theme = Theme.of(context);
    final TextStyle styleTitle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.secondary,
    );
    final TextStyle styleStats = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.tertiary,
    );
    final TextStyle styleButton = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.primary,
    );
    final TextStyle styleBuy = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final TextStyle styleLarge = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.primary,
    );
    final TextStyle styleSmall = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.secondary,
    );

    const List<int> credStore = <int>[30,60,100,200];
    const List<int> credCost = <int>[15,24,36,70];
    final List<String> vals = user.transactions.reversed.toList();

    return Center(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 80),
          Text(user.username, style: styleTitle),
          const SizedBox(height: 20),
          Text(
            'Credits: ${user.credits}\nParked this month: ${user.taken} \nReserved this month: ${user.given}',
            style: styleStats, 
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 60),
            ),
            icon: const Icon(Icons.browse_gallery, size: 30),
            label: Text('Logs', style: styleButton),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                builder: (final BuildContext context) => SizedBox(
                    height: 550,
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 20),
                        Text('Transactions:', style: styleTitle),
                        const SizedBox(height: 30),
                        if (vals.isEmpty) const Text('No transactions yet') else 
                        SizedBox(
                          height: 400,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: vals.length,
                            itemBuilder: (final BuildContext context, final int index) => SizedBox(
                                child: Center(child: Column(
                                  children: <Widget>[
                                    Text('$index: ${vals[index]}', style: styleLarge),
                                    Text('On ${user.transactionDates[index].toIso8601String()}', style: styleSmall),
                                    const SizedBox(height: 5),
                                  ],
                                )),
                              )
                          ),
                        ),
                      ],
                    ),
                  )
              );
            },
          ),
          const SizedBox(height: buttonSpace),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 60),
            ),
            icon: const Icon(Icons.settings, size: 30),
            label: Text('Settings', style: styleButton),
            onPressed: () { 
              if (kDebugMode) {
                print('Unemplemented feature!');
              }
            },
          ),
          const SizedBox(height: buttonSpace),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 60),
            ),
            icon: const Icon(Icons.store, size: 30),
            label: Text('Shop', style: styleButton),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                builder: (final BuildContext context) => SizedBox(
                    height: 550,
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 30),
                          Text('Shop', style: styleTitle),
                          const SizedBox(height: 20),
                          const Text('Buy credits:'),
                          const SizedBox(height: 30),
                          for (int i = 0; i < credStore.length; i++)
                            FilledButton(
                              onPressed: () => user.changeCreds(credStore[i]), 
                              child: Text(
                                'Buy ${credStore[i]}: \$${credCost[i]}',
                                style: styleBuy
                              )
                            ),
                            const SizedBox(height: 15),
                          const SizedBox(height: 25),
                          TextButton(
                            onPressed: () { 
                              if (kDebugMode) {
                                print('Unemplemented feature!');
                              }
                            },
                            child: const Text('Payment settings'),
                          )
                        ],
                      ),
                    ),
                  ),
              );
            },
          ),
        ],
      ),
    );
  }
}
