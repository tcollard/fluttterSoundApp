import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:myapp/utils/pages.dart';
import 'package:myapp/utils/cache.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Brightness _cacheBrigthness;
  bool darkModeState = false;
  var _cacheColor;
  List _listPages = AllPages().list;

  @override
  void initState() {
    Cache().getCacheOnKey('darkModeState').then((state) {
      setState(() {
        if (state != null && state != false) {
          _cacheBrigthness = Brightness.dark;
          darkModeState = true;
        } else {
          _cacheBrigthness = Brightness.light;
          darkModeState = false;
        }
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
        textTheme: GoogleFonts.robotoSlabTextTheme()
            .apply(bodyColor: (!darkModeState) ? Colors.black : Colors.white),
        accentColor: _cacheColor,
        primaryColor: _cacheColor,
        brightness: _cacheBrigthness,
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          title: 'Recording App',
          home: DefaultTabController(
            length: _listPages.length,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'My App',
                  style:
                      GoogleFonts.monoton(color: theme.scaffoldBackgroundColor),
                ),
                centerTitle: true,
                backgroundColor: theme.primaryColor,
                elevation: 0,
                bottom: TabBar(
                  isScrollable: false,
                  labelColor: theme.primaryColor,
                  labelStyle: GoogleFonts.robotoSlab(),
                  unselectedLabelColor: theme.scaffoldBackgroundColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: theme.scaffoldBackgroundColor,
                  ),
                  tabs: _listPages.map((page) {
                    return Tab(text: page.title, icon: Icon(page.icon));
                  }).toList(),
                ),
              ),
              body: TabBarView(
                children: _listPages.map((page) {
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
