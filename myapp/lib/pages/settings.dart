import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:myapp/utils/cache.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkModeState = false;
  var _tempMainColor;
  var _mainColor;

  @override
  void initState() {
    Cache().getCacheOnKey('darkModeState').then((state) {
      setState(() {
        print('Dark Cache State: $state');
        darkModeState = (state == null || state == false) ? false : true;
        print('DarkModeState: $darkModeState');
      });
    });
    super.initState();
  }

  void _openDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: content,
          actions: [
            FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                  DynamicTheme.of(context).setThemeData(new ThemeData(
                    primaryColor: _tempMainColor,
                    brightness: Theme.of(context).brightness,
                  ));
                  setState(() => _mainColor = _tempMainColor);
                }),
            FlatButton(
                child: Text('SUBMIT'),
                onPressed: () {
                  Cache().setCache('themeColor', _mainColor.value);
                  DynamicTheme.of(context).setThemeData(new ThemeData(
                    primaryColor: _mainColor,
                    brightness: Theme.of(context).brightness,
                  ));
                  Navigator.of(context).pop();
                  setState(() => _tempMainColor = _mainColor);
                }),
          ],
        );
      },
    );
  }

  void _openColorPicker() async {
    setState(() => _tempMainColor = Theme.of(context).primaryColor);
    _openDialog(
      "Choose color",
      MaterialColorPicker(
        allowShades: false,
        colors: fullMaterialColors,
        selectedColor: Theme.of(context).primaryColor,
        onMainColorChange: (color) => setState(() {
          _mainColor = color;
          DynamicTheme.of(context).setThemeData(new ThemeData(
            primaryColor: _mainColor,
            brightness: Theme.of(context).brightness,
          ));
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text('Dark mode'),
          Switch(
            value: darkModeState,
            onChanged: (value) {
              setState(() {
                darkModeState = value;
                Cache().setCache('darkModeState', value);
                DynamicTheme.of(context).setBrightness(
                    darkModeState ? Brightness.dark : Brightness.light);
                DynamicTheme.of(context).setThemeData(ThemeData(
                  primaryColor: Theme.of(context).primaryColor,
                  brightness:
                      (darkModeState) ? Brightness.dark : Brightness.light,
                ));
              });
            },
          ),
          RaisedButton(
            child: Text('Change color'),
            onPressed: _openColorPicker,
          ),
        ],
      ),
    );
  }
}
