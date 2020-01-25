import 'package:flutter/material.dart';
import 'package:myapp/common/customAppBar.dart';
import 'package:myapp/common/customDrawer.dart';

class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar: CustomAppBar(titleAppBar:'Home Page'),
          drawer: CustomDrawer(),
    );
  }
}