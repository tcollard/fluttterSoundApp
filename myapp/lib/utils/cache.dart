import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class Cache {
  File jsonFile;
  Directory dir;
  String fileName;
  bool fileExists;


  static final Cache _cache = Cache._internal();
 
  factory Cache() {
    return _cache;
  }

  Cache._internal() {
    fileName = "cache.json";
    fileExists = false;
  }
 
 

  checkJSONExist() async {
    Directory directory = await getApplicationDocumentsDirectory();
    this.dir = directory;
    this.jsonFile = File(dir.path + '/' + fileName);
    this.fileExists = await jsonFile.exists();
  }

  setJSON(String key, dynamic value) {
    Map<String, dynamic> content = {key: value};
    if (!this.fileExists) {
      createJSON(content);
    } else {
      Map<String, dynamic> jsonFileContent =
          jsonDecode(this.jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      this.jsonFile.writeAsStringSync(jsonEncode(jsonFileContent));
    }
  }

  createJSON(Map<String, dynamic> content) {
    File file = File(dir.path + '/' + fileName);
    file.create();
    this.fileExists = true;
    file.writeAsString(jsonEncode(content));
    return file;
  }

  setDarkMode(darkModeState) async {
    await this.checkJSONExist();
    setJSON('darkModeState', darkModeState);
  }

  getDarkMode() async {
    await this.checkJSONExist();
    if (this.fileExists) {
      var jsonContent = await jsonDecode(this.jsonFile.readAsStringSync());
      return jsonContent['darkModeState'] ?? false;
    } else {
      return false;
    }
  }

  getColor() async {
    await this.checkJSONExist();
    if (fileExists) {
      var jsonContent = await jsonDecode(this.jsonFile.readAsStringSync());
      return jsonContent['themeColor'] ?? 0;
    } else {
      return 0;
    }
  }

  setColor(color) async {
    await this.checkJSONExist();
    this.setJSON('themeColor', color);
  }

  saveRecord(name, path) async {
    Map<String, dynamic> record = {'name': name, 'path': path};
    List content = [];
    await this.checkJSONExist();
    if (this.fileExists) {
      var jsonContent = await jsonDecode(this.jsonFile.readAsStringSync());
      content = jsonContent['records'] ?? [];
      int index = content.indexWhere((elem) => elem.toString() == record.toString());

      if (index != -1) content.removeAt(index);
    }
    content.add(record);
    this.setJSON('records', content);
  }

  getRecord() async {
    // List listRecords = [];
    await this.checkJSONExist();
    if (this.fileExists) {
      var jsonContent = await jsonDecode(this.jsonFile.readAsStringSync());

      return jsonContent['records'];
    } else {
      return null;
    }
  }
}
