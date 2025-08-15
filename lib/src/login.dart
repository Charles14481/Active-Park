import 'dart:async';

import 'package:active_park/src/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Page that lets users log in
/// 
/// (currently no backend, info stored in state)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle styleTitle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
    );
    final UserModel user = context.watch<UserModel>();

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
                Text("Let's get you signed in", style: styleTitle),
                const SizedBox(height: 40),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Username',
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Password',
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  child: const Text('Login'),
                  onPressed: () {
                    user..setName(usernameController.text)
                    ..setPassword(passwordController.text);
                    unawaited(Navigator.pushNamed(context,'/dashboard'));
                  }
                ),
                const SizedBox(height: 100),
                TextButton(
                  child: const Text('Sign up'), 
                  onPressed: () {
                    unawaited(Navigator.pushNamed(context,'/signup'));
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
