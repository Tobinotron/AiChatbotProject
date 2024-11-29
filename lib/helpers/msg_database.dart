
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ChatMessage {
  int id = 0; // ObjectBox requires an ID field; 0 is auto-incremented.

  String sender;
  String message;

  ChatMessage({
    required this.sender,
    required this.message,
  });
}
//  

void addToDatabase(String name, String message) {
  print("Message '" + message + "' from " + name + " was succesfully added to database.");
}

