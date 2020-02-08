import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/common/dialog.dart';
import 'package:myapp/utils/cache.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkModeState = false;
  Brightness brightness;
  AllDialog _dialog = AllDialog();

  @override
  void initState() {
    Cache().getCacheOnKey('darkModeState').then((state) {
      if (!mounted) return;
      setState(() {
        darkModeState = (state == null || state == false) ? false : true;
      });
    });
    super.initState();
  }

  chooseColor() {
    return MaterialColorPicker(
      physics: NeverScrollableScrollPhysics(),
      elevation: 1,
      shrinkWrap: true,
      allowShades: false,
      colors: fullMaterialColors,
      circleSize: 35,
      selectedColor: Theme.of(context).primaryColor,
      onMainColorChange: (_color) => setState(() {
        _changeColorSettings(_color);
        DynamicTheme.of(context).setThemeData(new ThemeData(
          textTheme: GoogleFonts.robotoSlabTextTheme().apply(
            bodyColor: (darkModeState) ? Colors.white : Colors.black,
          ),
          accentColor: _color,
          primaryColor: _color,
          brightness: brightness,
          scaffoldBackgroundColor:
              (darkModeState) ? Colors.grey[850] : Colors.grey.shade200,
        ));
        Cache().setCache('themeColor', _color.value);
        Cache().setCache('darkModeState', darkModeState);
      }),
    );
  }

  _changeColorSettings(_color) {
    _checkPermission();
    if (_color.value == Colors.white.value ||
        _color.value == Colors.limeAccent.value ||
        _color.value == Colors.yellowAccent.value) {
      brightness = Brightness.dark;
      darkModeState = true;
    } else {
      brightness = Brightness.light;
      darkModeState = false;
    }
  }

  _checkPermission() {
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage)
        .then((permission) {
      if (permission != PermissionStatus.granted) {
        _dialog.callInfoDialog(context, 'ACCESS PERMISSION',
            'Please give me your permissions to record and save 🙏', () async {
          await PermissionHandler().openAppSettings();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Text(
                'Theme Color',
                style: TextStyle(fontSize: 20.0),
              ),
            )
          ],
        ),
        chooseColor(),
        Divider(
          color: Colors.grey[500],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Dark mode',
                style: TextStyle(fontSize: 20.0),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Switch(
              value: darkModeState,
              onChanged: (value) {
                _checkPermission();
                setState(() {
                  darkModeState = value;
                  Cache().setCache('darkModeState', value);
                  DynamicTheme.of(context).setThemeData(ThemeData(
                    textTheme: GoogleFonts.robotoSlabTextTheme().apply(
                      bodyColor: (darkModeState) ? Colors.white : Colors.black,
                    ),
                    accentColor: Theme.of(context).accentColor,
                    primaryColor: Theme.of(context).primaryColor,
                    brightness:
                        (darkModeState) ? Brightness.dark : Brightness.light,
                  ));
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
