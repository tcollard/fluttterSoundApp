import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

File jsonFile;
Directory dir;
String fileName = "cache.json";
bool fileExists = false;

_checkJSONExist() async {
  await getApplicationDocumentsDirectory().then((Directory directory) async {
    dir = directory;
    jsonFile = File(dir.path + '/' + fileName);
    fileExists = await jsonFile.exists();
  });
}

_setJSON(String key, dynamic value) {
  Map<String, dynamic> content = {key: value};
  if (!fileExists) {
    _createJSON(content);
  } else {
    Map<String, dynamic> jsonFileContent =
        jsonDecode(jsonFile.readAsStringSync());
    jsonFileContent.addAll(content);
    jsonFile.writeAsStringSync(jsonEncode(jsonFileContent));
  }
}

_createJSON(Map<String, dynamic> content) {
  File file = File(dir.path + '/' + fileName);
  file.create();
  fileExists = true;
  file.writeAsString(jsonEncode(content));
  return file;
}

class Cache {
  static setDarkMode(darkModeState) async {
    await _checkJSONExist();
    _setJSON('darkModeState', darkModeState);
  }

  static getDarkMode() async {
    await _checkJSONExist();
    if ((fileExists)) {
      var jsonContent = await jsonDecode(jsonFile.readAsStringSync());
      return jsonContent['darkModeState'] ?? false;
    } else {
      return false;
    }
  }

  static getColor() async {
    await _checkJSONExist();
    if ((fileExists)) {
      var jsonContent = await jsonDecode(jsonFile.readAsStringSync());
      return jsonContent['themeColor'];
    } else {
      return 0;
    }
  }

  static setColor(color) async {
    await _checkJSONExist();
    _setJSON('themeColor', color);
  }

  static saveRecord(name, path) async {
    Map<String, dynamic> record = {'name': name, 'path': path};
    List content = [];
    await _checkJSONExist();
    if ((fileExists)) {
      var jsonContent = await jsonDecode(jsonFile.readAsStringSync());

      content = jsonContent['records'] ?? [];
      int index = content.indexWhere((elem) => elem.toString() == record.toString());

      if (index != -1) content.removeAt(index);
    }
    content.add(record);
    _setJSON('records', content);
  }
}
