import "package:cloud_firestore/cloud_firestore.dart";

  class ChatModel{
  final String userId;
  final String userName;
  final String message;
  final Timestamp timestamp;

  ChatModel({
    required this.timestamp,
    required this.message,
    required this.userName,
    required this.userId
  });

  ChatModel.fromSnapshot(QueryDocumentSnapshot doc) :
      userId= doc["userId"] as String,
      userName= doc["userName"] as String,
      message = doc["message"] as String,
      timestamp = doc["timeStamp"] as Timestamp;
}