import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:myapp/utils/pages.dart';
import 'package:myapp/utils/cache.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Brightness _cacheBrigthness;
  var _cacheColor;
  List listPages = AllPages().list;

  @override
  void initState() {
    Cache().getCacheOnKey('darkModeState').then((state) {
      setState(() {
        _cacheBrigthness = (state != null && state != false)
            ? Brightness.dark
            : Brightness.light;
      });
    });
    Cache().getCacheOnKey('themeColor').then((data) {
      setState(() {
        _cacheColor = (data != null) ? Color(data) : Colors.blue;
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
          home: DefaultTabController(
            length: listPages.length,
            child: Scaffold(
              appBar: AppBar(
                title: Text('My App'),
                bottom: TabBar(
                  isScrollable: true,
                  tabs: listPages.map((page) {
                    return Tab(text: page.title, icon: Icon(page.icon));
                  }).toList(),
                ),
              ),
              body: TabBarView(
                children: listPages.map((page) {
                  return Container(
                    child: page.pageName,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
