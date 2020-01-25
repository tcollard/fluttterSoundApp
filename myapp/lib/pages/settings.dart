import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:myapp/common/customAppBar.dart';
import 'package:myapp/common/customDrawer.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:myapp/utils/cache.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkModeState;
  ColorSwatch _tempMainColor;
  ColorSwatch _mainColor = Colors.blue;

  @override
  void initState() {
    Cache.getDarkMode().then((state) {
      setState(() {
        darkModeState = state;
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
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _mainColor = _tempMainColor);
              }
            ),
          ],
        );
      },
    );
  }

  void _openColorPicker() async {
    _openDialog(
      "Choose color",
      MaterialColorPicker(
        allowShades: false,
        colors: fullMaterialColors,
        selectedColor: _mainColor,
        onMainColorChange: (color) => setState(() {
          DynamicTheme.of(context).setThemeData(new ThemeData(
            primaryColor: color,
            brightness: Theme.of(context).brightness,
          ));
          Cache.setColor(color.value);
          return _tempMainColor = color;
        }),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleAppBar: 'Settings Page'),
      drawer: CustomDrawer(),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('Dark mode'),
            Switch(
              value: darkModeState,
              onChanged: (value) {
                setState(() {
                  darkModeState = value;
                  Cache.setDarkMode(value);
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
      ),
    );
  }
}
