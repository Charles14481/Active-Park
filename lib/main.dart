import 'package:active_park/src/dashboard.dart';
import 'package:active_park/src/login.dart';
import 'package:active_park/src/markers.dart';
import 'package:active_park/src/signup.dart';
import 'package:active_park/src/usermodel.dart';
import 'package:active_park/src/welcomepage.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

/// Runs app
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) => MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<UserModel>(create: (_) => UserModel()),
        ChangeNotifierProvider<MapModel>(create: (_) => MapModel()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: const WelcomePage(pageTitle: 'Start'),
        routes: <String, WidgetBuilder>{
          '/signup': (final BuildContext context) => const SignUpPage(),
          '/login': (final BuildContext context) => const LoginPage(),
          '/dashboard': (final BuildContext context) => const DashboardPage(),
        },
      ),
    );
}
