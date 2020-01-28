import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('My Name'),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              title: Text('Sound Library'),
              onTap: () {
                Navigator.pushNamed(context, '/soundLib');
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}
