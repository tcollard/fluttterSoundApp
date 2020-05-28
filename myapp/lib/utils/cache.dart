import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class Cache {
  static final Cache _cache = Cache._internal();

  File jsonFile;
  Directory dir;
  String fileName = "cache.json";
  bool fileExists = false;

  factory Cache() => _cache;

  Cache._internal();

  //JSON FUNCTION

  checkJSONExist() async {
    Directory directory = await getApplicationDocumentsDirectory();
    dir = directory;
    jsonFile = File(dir.path + '/' + fileName);
    fileExists = await jsonFile.exists();
  }

  createJSON(Map<String, dynamic> content) async {
    File file = File(dir.path + '/' + fileName);
    file.create();
    fileExists = true;
    file.writeAsString(jsonEncode(content));
    return file;
  }

  setJSON(String key, dynamic value) {
    Map<String, dynamic> content = {key: value};
    if (!fileExists) {
      createJSON(content);
    } else {
      Map<String, dynamic> jsonFileContent =
          jsonDecode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(jsonEncode(jsonFileContent));
    }
  }

  // key: darkModeState / themeColor / records
  setCache(String key, dynamic value) async {
    if (fileExists == false) await checkJSONExist();
    setJSON(key, value);
  }

  getCacheOnKey(String key) async {
    if (fileExists == false) await checkJSONExist();
    if (fileExists) {
      var jsonContent = await jsonDecode(jsonFile.readAsStringSync());
      return jsonContent[key] ?? null;
    } else {
      return null;
    }
  }

  // Cache Records
  saveRecord(name, path) async {
    Map<String, dynamic> record;
    List content = await getCacheOnKey('records') ?? [];
    if (content == null) {
      content = [];
    }
    int index =
        content.indexWhere((elem) => elem.toString() == record.toString());

    if (index != -1) content.removeAt(index) && updateRecordsIndex(index);

    record = {'name': name, 'path': path, 'index': content.length};
    content.add(record);
    setJSON('records', content);
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
    var jsonContent = await jsonDecode(jsonFile.readAsStringSync());
    content = jsonContent['records'];
    content[elem['index']][key] = value;
    jsonFile.writeAsStringSync(jsonEncode(jsonContent));
  }

  removeRecord(elem) async {
    List content = [];
    var jsonContent = await jsonDecode(jsonFile.readAsStringSync());
    content = jsonContent['records'];
    int i =
        content.indexWhere((record) => record.toString() == elem.toString());
    File(content[i]['path']).delete();
    content.removeAt(i);
    jsonFile.writeAsStringSync(jsonEncode(jsonContent));
  }

  updateListRecords() async {
    var recordsJson = await getCacheOnKey('records');
    var jsonContent = await jsonDecode(jsonFile.readAsStringSync());
    for (var i = 0; i < recordsJson.length; i++) {
      if (!File(recordsJson[i]['path']).existsSync()) {
        recordsJson.removeAt(i);
        i -= 1;
      }
    }
    jsonFile.writeAsStringSync(jsonEncode(jsonContent));
    recordsJson
      ..sort((a, b) {
        return (a['index'] as int).compareTo((b['index'] as int));
      });
    return recordsJson;
  }

  saveRecordOrder(list) {
    for (var i = 0; i < list.length; i++) {
      list[i]['index'] = i;
    }
    setCache('records', list);
  }
}
