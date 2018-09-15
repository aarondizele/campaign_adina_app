import 'dart:convert';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import '../model/model.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  String _error;

  factory AppDatabase() => _instance;

  static Database _db;

  String get error => _error;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  AppDatabase._internal();

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "database.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE Users(id INTEGER PRIMARY KEY AUTOINCREMENT, lastName TEXT, firstName TEXT, phoneNumber TEXT NOT NULL)");

    print("Users DB created!");

    await db.execute(
        "CREATE TABLE Messages(id INTEGER PRIMARY KEY AUTOINCREMENT, messageType TEXT NOT NULL, content TEXT, mediaUrl TEXT, createdAt TEXT NOT NULL, timestamp TEXT NOT NULL, userId TEXT, district TEXT, province TEXT, status INTEGER, statusName TEXT, cachedUrl STRING)");

    print("Messages DB created!");
  }

  /// USERS Table
  ///

  Future<int> addUser(User user) async {
    var dbClient = await db;
    try {
      int res = await dbClient.insert("Users", user.toMap());
      print("User added $res");
      return res;
    } catch (e) {
      var res = await updateUser(user);
      return res;
    }
  }

  Future<int> deleteUser(String id) async {
    var dbClient = await db;
    int res = await dbClient.delete("Users", where: "id = ?", whereArgs: [id]);
    print("User deteled $res");
    return res;
  }

  Future<int> updateUser(User user) async {
    var dbClient = await db;
    int res = await dbClient
        .update("Users", user.toMap(), where: "id = ?", whereArgs: [user.id]);
    print("User updated $res");
    return res;
  }

  Future<User> getUser(String id) async {
    var dbClient = await db;
    var res = await dbClient.query("Users", where: "id = ?", whereArgs: [id]);
    if (res.length == 0) return null;
    return User.fromJson(res[0]);
  }

  /// MESSAGES TABLE
  ///
  ///

  Future<int> sendMessage(Messaging message) async {
    var dbClient = await db;
    int res = await dbClient.update("Messages", message.toMap(),
        where: "id = ?", whereArgs: [message.id]);
    print("Message added $res");
    return res;
  }

  Future<int> saveMessage(Messaging message) async {
    var dbClient = await db;
    int res;
    try {
      if (message.status == 1) {
        res = await dbClient.insert("Messages", message.toMap());
        print(message.toMap());
      } else if (message.status == 0) {
        res = await dbClient.insert("Messages", message.toMap());

        if (message.messageType == 'VOICE') {
          await uploadVoice(message.cachedUrl).then((mediaUrl) async {
            message.id = res.toString();
            message.mediaUrl = mediaUrl;
            message.status = 1;
            message.statusName = 'sync';
            await updateMessage(message);
            print(message.toMap());
          });
        }
      }

      print("Message added $res");
      return res;
    } catch (e) {
      _error = e.toString();
      res = await updateMessage(message);
      return res;
    }
  }

  Future<int> deleteMessage(String id) async {
    var dbClient = await db;
    int res =
        await dbClient.delete("Messages", where: "id = ?", whereArgs: [id]);
    print("Message deteled $res");
    return res;
  }

  Future<int> updateMessage(Messaging message) async {
    var dbClient = await db;
    int res;

    if (message.status == 1) {
      res = await dbClient.update("Messages", message.toMap(),
          where: "id = ?", whereArgs: [message.id]);
    }

    if (message.status == 0) {
      res = await dbClient.update("Messages", message.toMap(),
          where: "id = ?", whereArgs: [message.id]);

      await uploadVoice(message.cachedUrl).then((mediaUrl) async {
        message.id = message.id;
        message.mediaUrl = mediaUrl;
        message.status = 1;
        message.statusName = 'sync';

        await updateMessage(message);
        print(message.toMap());
      });
    }
    print("Message updated $res");
    return res;
  }

  Future<Null> onSendMessage(Messaging message) async {
    var dbClient = await db;
    int res;
    int status;
    String statusName;
    try {
      var body;
      if (message.id == null) {
        try {
          res = await dbClient.insert("Messages", message.toMap());
          if (message.status == 0) {
            await uploadVoice(message.cachedUrl).then((mediaUrl) async {
              status = 1;
              statusName = 'sync';

              message.id = res.toString();
              message.mediaUrl = mediaUrl;
              message.status = status;
              message.statusName = statusName;
              await updateMessage(message);

              body = jsonEncode({
                'content': message.content,
                'messageType': message.messageType,
                'mediaUrl': mediaUrl,
                'province': message.province,
                'userId': message.userId,
                'status': message.statusName.toUpperCase()
              });
            });
          } else {
            body = jsonEncode({
              'content': message.content,
              'messageType': message.messageType,
              'mediaUrl': message.mediaUrl,
              'province': message.province,
              'userId': message.userId,
              'status': message.statusName.toUpperCase()
            });
          }
        } catch (e) {
          res = await updateMessage(message);
        }
      } else {
        body = jsonEncode({
          'content': message.content,
          'messageType': message.messageType,
          'mediaUrl': message.mediaUrl,
          'province': message.province,
          'userId': message.userId,
          'status': message.statusName.toUpperCase()
        });
      }
      var url = "http://192.168.43.140:8080/api/publications";
      var client = new http.Client();
      await client.post(url,
          body: body,
          headers: {"Content-Type": "application/json"})
      .then((response) async {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
        if (message.id == null) message.id = res.toString();
        message.statusName = "sent";
        await updateMessage(message);
      })
      .catchError((e) async {
        print(e.toString());
        if (message.id == null) message.id = res.toString();
        message.statusName = "error";

        Messaging _message = Messaging(
          id: message.id,
          messageType: message.messageType,
          createdAt: message.createdAt,
          timestamp: message.timestamp,
          userId: message.userId,
          content: message.content,
          mediaUrl: message.mediaUrl,
          district: message.district,
          province: message.province,
          cachedUrl: message.cachedUrl,
          status: message.status,
          statusName: message.statusName
        );
        await updateMessage(_message);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<Messaging>> getMessages() async {
    var dbClient = await db;
    List<Map> res = await dbClient.query("Messages");
    List<Messaging> messages = res.map((m) => Messaging.fromJson(m)).toList();
    return messages;
  }

  Future<Messaging> getMessage(String id) async {
    var dbClient = await db;
    var res =
        await dbClient.query("Messages", where: "id = ?", whereArgs: [id]);
    if (res.length == 0) return null;
    return Messaging.fromJson(res[0]);
  }

  /// CLOSE DB
  Future closeDb() async {
    var dbClient = await db;
    dbClient.close();
  }
}

/// UPLOAD VOICE ON FIREBASE STORAGE
Future<String> uploadVoice(String cachedUrl) async {
  try {
    final File _cachedUrl = File(cachedUrl);
    final audio = _cachedUrl.readAsBytesSync();
    final Directory tempDir = Directory.systemTemp;
    final String filename = audioName(cachedUrl);
    final File file = File('${tempDir.path}/$filename');
    file.writeAsBytes(audio, mode: FileMode.write);

    final StorageReference ref = FirebaseStorage.instance.ref().child(filename);
    final StorageUploadTask task = ref.putFile(file);
    final Uri downloadUrl = (await task.future).downloadUrl;
    print(downloadUrl);
    return downloadUrl.toString();
  } catch (e) {
    return e.toString();
  }
}

/// GET AUDIO NAME FORMAT
String audioName(path) {
  final RegExp regExp1 = RegExp('([^?/]*\.(m4a))');
  final RegExp regExp2 = RegExp('([^?/]*\.(mp3))');
  final RegExp regExp3 = RegExp('([^?/]*\.(aac))');
  String pathName;
  if (regExp1.hasMatch(path.toString())) {
    pathName = regExp1.stringMatch(path.toString().trim().replaceAll(' ', ''));
  } else if (regExp2.hasMatch(path.toString())) {
    pathName = regExp2.stringMatch(path.toString().trim().replaceAll(' ', ''));
  }
  if (regExp3.hasMatch(path.toString())) {
    pathName = regExp3.stringMatch(path.toString().trim().replaceAll(' ', ''));
  }
  return pathName;
}
