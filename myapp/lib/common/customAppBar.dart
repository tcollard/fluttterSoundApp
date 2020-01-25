import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleAppBar;

  CustomAppBar({@required this.titleAppBar});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(this.titleAppBar),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
