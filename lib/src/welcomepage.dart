import 'dart:async';

import 'package:flutter/material.dart';

/// First page shown, displays start screen
class WelcomePage extends StatefulWidget {

  const WelcomePage({required this.pageTitle, super.key});
  final String pageTitle;

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle styleTitle = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.primary,
    );
    final TextStyle styleTitle2 = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
    );
    final TextStyle styleSecondary = theme.textTheme.headlineLarge!.copyWith(
      color: theme.colorScheme.secondary,
    );
    final TextStyle styleButton = theme.textTheme.headlineMedium!.copyWith(
      color: theme.colorScheme.tertiary,
    );
    
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 60),
              Image(
                image: ResizeImage(
                  const AssetImage('assets/red-car.png'),
                  width: (MediaQuery.sizeOf(context).width * 1.5).toInt(), // Half of the screen's width.
                ),
              ),
              const SizedBox(height: 40),
              Text('Welcome to', style: styleTitle2, textAlign: TextAlign.center),
              Text('Active Park', style: styleTitle, textAlign: TextAlign.center),
              const SizedBox(height: 30),
              Text('Get started', style: styleSecondary, textAlign: TextAlign.center),
              const SizedBox(height: 30),
              SizedBox(
                width: 180,
                height: 60,
                child: ElevatedButton(
                  child: Text('Login', style: styleButton), 
                  onPressed: () {
                    unawaited(Navigator.pushNamed(context, '/login'));
                  }
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 180,
                height: 60,
                child: ElevatedButton(
                  child: Text('Sign Up', style: styleButton), 
                  onPressed: () {
                    unawaited(Navigator.pushNamed(context, '/signup'));
                  }
                ),
              ),
            ],
          ),
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
