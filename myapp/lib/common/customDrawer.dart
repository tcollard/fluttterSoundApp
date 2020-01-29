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
                if (ModalRoute.of(context).settings.name != '/') {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              title: Text('Sound Library'),
              onTap: () {
                if (ModalRoute.of(context).settings.name != '/soundLib') {
                  Navigator.pushNamed(context, '/soundLib');
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                if (ModalRoute.of(context).settings.name != '/settings') {
                  Navigator.pushNamed(context, '/settings');
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
