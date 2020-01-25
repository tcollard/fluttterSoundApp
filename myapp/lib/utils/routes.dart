import 'package:myapp/pages/home.dart';
import 'package:myapp/pages/recorder.dart';
import 'package:myapp/pages/settings.dart';

class AllRoutes {
  static var route = {
    '/': (context) => HomePage(),
    '/recorder': (context) => RecorderPage(),
    '/settings': (context) => SettingsPage(),
  };
}