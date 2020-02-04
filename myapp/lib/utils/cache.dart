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

  //JSON FUNCTION

  checkJSONExist() async {
    Directory directory = await getApplicationDocumentsDirectory();
    this.dir = directory;
    this.jsonFile = File(dir.path + '/' + fileName);
    this.fileExists = await jsonFile.exists();
  }

  createJSON(Map<String, dynamic> content) {
    File file = File(dir.path + '/' + fileName);
    file.create();
    this.fileExists = true;
    file.writeAsString(jsonEncode(content));
    return file;
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

  // key: darkModeState / themeColor / records
  setCache(String key, dynamic value) async {
    if (this.fileExists == false) await this.checkJSONExist();
    setJSON(key, value);
  }

  getCacheOnKey(String key) async {
    if (this.fileExists == false) await this.checkJSONExist();
    if (this.fileExists) {
      var jsonContent = await jsonDecode(this.jsonFile.readAsStringSync());
      return jsonContent[key] ?? null;
    } else {
      return null;
    }
  }

  // Cache Records
  saveRecord(name, path) async {
    Map<String, dynamic> record;
    List content = await getCacheOnKey('records') ?? [];
    int index =
        content.indexWhere((elem) => elem.toString() == record.toString());

    if (index != -1) content.removeAt(index) && updateRecordsIndex(index);

    record = {'name': name, 'path': path, 'index': content.length};
    content.add(record);
    this.setJSON('records', content);
  }

  updateRecordsIndex(allRecords) {
    //Update to keep position from list drag & drop
    for (var i = 0; i < allRecords.length; i++) {
      if (allRecords[i]["index"] != i) {
        allRecords[i]["index"] = i;
      }
    }
  }

  updateRecord(key, value, elem) async {
    List content = [];
    var jsonContent = await jsonDecode(this.jsonFile.readAsStringSync());
    content = jsonContent['records'];
    content[elem['index']][key] = value;
    this.jsonFile.writeAsStringSync(jsonEncode(jsonContent));
  }

  removeRecord(elem) async {
    List content = [];
    var jsonContent = await jsonDecode(this.jsonFile.readAsStringSync());
    content = jsonContent['records'];
    int i = content.indexWhere((record) => record.toString() == elem.toString());
    File(content[i]['path']).delete();
    content.removeAt(i);
    this.jsonFile.writeAsStringSync(jsonEncode(jsonContent));
  }

  updateListRecords() async {
    var recordsJson = await this.getCacheOnKey('records');
    var jsonContent = await jsonDecode(this.jsonFile.readAsStringSync());
    for (var i = 0; i < recordsJson.length; i++) {
      if (!File(recordsJson[i]['path']).existsSync()) {
        recordsJson.removeAt(i);
        i -= 1;
      }
    }
    this.jsonFile.writeAsStringSync(jsonEncode(jsonContent));
    return recordsJson;
  }
}
