import 'package:meta/meta.dart';

class User {
  User({this.id, this.lastName, this.firstName, @required this.phoneNumber});

  String id, lastName, firstName, phoneNumber;

  User.fromJson(Map json) 
    : id = json['id'].toString(),
      lastName = json['lastName'],
      firstName = json['firstName'],
      phoneNumber = json['phoneNumber'];

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['lastName'] = lastName;
    map['firstName'] = firstName;
    map['phoneNumber'] = phoneNumber;
    return map;
  }
}

class Messaging {
  Messaging({this.id, @required this.messageType, this.content, this.mediaUrl, @required this.createdAt, this.timestamp, this.userId, this.district, this.province, this.statusName, this.status, this.cachedUrl});

  String id, messageType, content, mediaUrl, createdAt, timestamp, userId, district, province, statusName, cachedUrl;
  int status;

  Messaging.fromJson(Map json) 
    : id = json['id'].toString(),
      messageType = json['messageType'],
      content = json['content'],
      mediaUrl = json['mediaUrl'],
      createdAt = json['createdAt'].toString(),
      timestamp = json['timestamp'].toString(),
      userId = json['userId'],
      district = json['district'],
      province = json['province'],
      statusName = json['statusName'],
      status = json['status'],
      cachedUrl = json['cachedUrl'];

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['messageType'] = messageType;
    map['content'] = content;
    map['mediaUrl'] = mediaUrl;
    map['createdAt'] = createdAt;
    map['timestamp'] = timestamp;
    map['userId'] = userId;
    map['district'] = district;
    map['province'] = province;
    map['statusName'] = statusName;
    map['status'] = status;
    map['cachedUrl'] = cachedUrl;
    return map;
  }
}