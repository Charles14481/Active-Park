import 'package:active_park/src/accountpage.dart';
import 'package:active_park/src/findpage.dart';
import 'package:active_park/src/homepage.dart';
import 'package:active_park/src/postpage.dart';
import 'package:active_park/src/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// UI that handles switching between subpages
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});


  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  // Add this list of pages to preserve state
  final List<Widget> _pages = <Widget>[
    const HomePage(),
    const FindPage(),
    const PostPage(),
    const AccountPage(),
  ];

  @override
  Widget build(final BuildContext context) {
    final UserModel user = context.watch<UserModel>();

    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Text(
                user.username,
              ),
              const Spacer(),
              Text(
                'Credits: ${user.credits}',
              ),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.cyan[900],
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              label: 'Find',
              backgroundColor: Colors.purple[900],
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.directions_car),
              label: 'Post',
              backgroundColor: Colors.yellow[900],
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'Account',
              backgroundColor: Colors.grey[800],
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.white,
          onTap: (final int value) {
            setState(() {
              selectedIndex = value;
            });
          },
        ),
      )
    );
  }
}
