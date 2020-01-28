// import 'package:myapp/pages/home.dart';
import 'package:myapp/pages/recorder.dart';
import 'package:myapp/pages/settings.dart';
import 'package:myapp/pages/soundLib.dart';

class AllRoutes {
  static var route = {
    // '/': (context) => HomePage(),
    '/': (context) => RecorderPage(),
    '/soundLib': (context) => SoundLib(),
    '/settings': (context) => SettingsPage(),
  };
}