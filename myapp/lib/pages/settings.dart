import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/cache.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkModeState = false;

  @override
  void initState() {
    Cache().getCacheOnKey('darkModeState').then((state) {
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
      selectedColor: Theme.of(context).primaryColor,
      onMainColorChange: (_color) => setState(() {
        DynamicTheme.of(context).setThemeData(new ThemeData(
          textTheme: GoogleFonts.robotoSlabTextTheme().apply(bodyColor: (darkModeState) ? Colors.white : Colors.black),
          accentColor: _color,
          primaryColor: _color,
          brightness: Theme.of(context).brightness,
        ));
        Cache().setCache('themeColor', _color.value);
      }),
    );
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Dark mode',
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Switch(
              value: darkModeState,
              onChanged: (value) {
                setState(() {
                  darkModeState = value;
                  Cache().setCache('darkModeState', value);
                  DynamicTheme.of(context).setBrightness(
                      darkModeState ? Brightness.dark : Brightness.light);
                  DynamicTheme.of(context).setThemeData(ThemeData(
                    textTheme: GoogleFonts.robotoSlabTextTheme().apply(bodyColor: (darkModeState) ? Colors.white : Colors.black),
                    accentColor: Theme.of(context).accentColor,
                    primaryColor: Theme.of(context).primaryColor,
                    brightness:
                        (darkModeState) ? Brightness.dark : Brightness.light,
                  ));
                });
              },
            ),
          ],
        )
      ],
    );
  }
}
