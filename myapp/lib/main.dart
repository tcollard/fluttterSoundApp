import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:myapp/utils/routes.dart';
import 'package:myapp/utils/cache.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Brightness _cacheBrigthness;
  var _cacheColor;

  @override
  void initState() {
    Cache.getDarkMode().then((state) {
      setState(() {
        _cacheBrigthness = (state) ? Brightness.dark : Brightness.light;
      });
    });
    Cache.getColor().then((data) {
      setState(() {
        _cacheColor = (data != 0) ? Color(data) : Colors.blue;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: _cacheBrigthness,
      data: (brightness) => ThemeData(
        primaryColor: _cacheColor,
        brightness: brightness,
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Sound App',
          theme: theme,
          initialRoute: '/',
          routes: AllRoutes.route,
        );
      },
    );
  }
}