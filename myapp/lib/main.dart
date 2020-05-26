import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:myapp/common/timer.dart';
import 'package:myapp/utils/pages.dart';
import 'package:myapp/utils/cache.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/services.dart';

void main() {
  final timerService = TimerService();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then((_) {
    runApp(
      TimerServiceProvider(
        service: timerService,
        child: MySplashScreen(),
      ),
    );
  });
}

class MySplashScreen extends StatelessWidget {
  const MySplashScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recording App',
      home: SplashScreen.navigate(
        name: 'lib/asset/animation/MyMic.flr',
        next: (_) => MyApp(),
        until: () => Future.delayed(Duration(seconds: 0)),
        startAnimation: 'StartAnimation',
        backgroundColor: Colors.white,
      ),
    );
  }
}

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
      if (!mounted) return;
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
      if (!mounted) return;
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
        scaffoldBackgroundColor:
            (!darkModeState) ? Colors.grey.shade200 : Colors.grey[850],
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
                  'MyMic',
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
