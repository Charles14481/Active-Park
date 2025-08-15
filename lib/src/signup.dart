import 'dart:async';

import 'package:flutter/material.dart';

/// Page to sign up for account
/// 
/// (currently not connected to backend)
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});


  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle styleTitle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
    );

    return Scaffold(
          body: Column(
            children: <Widget>[
              Image(
                image: ResizeImage(
                  const AssetImage('assets/parking-lot.jpg'),
                  width: (MediaQuery.sizeOf(context).width * 1.5).toInt(), // Half of the screen's width.
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.sstart,
                  children: <Widget>[
                    const SizedBox(height: 40),
                    Text('Create your account', style: styleTitle),
                    const SizedBox(height: 40),
                    const TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Username',
                      ),
                    ),
                    const SizedBox(height: 30),
                    const TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 30),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Password',
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      child: const Text('Sign Up'),
                      onPressed: () {
                        unawaited(Navigator.pushNamed(context,'/dashboard'));
                      }
                    ),
                    const SizedBox(height: 100),
                    TextButton(
                      child: const Text('Log in'), 
                      onPressed: () {
                        unawaited(Navigator.pushNamed(context,'/login'));
                      }
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
