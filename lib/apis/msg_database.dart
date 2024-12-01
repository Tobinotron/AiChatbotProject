import 'package:flutter/widgets.dart';
import 'package:webcrawler/apis/gemini_embed.dart' as embedder;
import 'package:supabase_flutter/supabase_flutter.dart';

//import 'package:tflite_flutter/tflite_flutter.dart';
/*
import 'package:webcrawler/objectbox/objectbox.g.dart'; // This file is generated.
late final Store store;
late final Box<ChatMessage> chatBox;

void initializeDatabase() {
  store = Store(getObjectBoxModel());
  chatBox = store.box<ChatMessage>();
}

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
*/

const dbUrl = 'https://wbaevfuzblqrfkfppibf.supabase.co';
const String apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndiYWV2ZnV6YmxxcmZrZnBwaWJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI5MTc2NDksImV4cCI6MjA0ODQ5MzY0OX0.vQM77au1zrN4WRSGeAxsRu2PZObc0TE7bubdsvZlkHY';

Future<void> initDb() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: dbUrl,
      anonKey: apiKey,
    );
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

void addToDatabase(String name, String message) async {
  List<double> embedding = await embedder.generateText(message);
  print("Message '" + message + "' from " + name + " was succesfully added to database. It has embedding value: '" + embedding.toString() + "'");
}

Future<void> addMessageToDatabase(String person, String sender, String message) async {
  try {
    // Insert the data into the 'message_history' table
    await supabase
      .from('message_history')
      .insert({
        'person': person,
        'sender': sender,
        'message': message,
      });

    print('Message added successfully');
  } catch (e) {
    print('Error adding message to database: $e');
  }
}