import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:webcrawler/apis/gemini_embed.dart' as embedder;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'prompt_generator.dart' as prompt_gen;

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

/*
  Adds a RAG message from the WhatsApp ChatFile to the Database.
  Input:
    - String person  : The name of the person that sent the message
    - String message : The contens of the message as a String. This message will be embedded and also become a field in the Dataset.
  Output:
    - void
*/
void addRAGToDatabase(String person, String message) async {
  List<double> embedding = await embedder.generateText(message);

  try {
    // Insert the data into the 'rag_messages' table
    await supabase
      .from('rag_messages')
      .insert({
        'person': person,
        'embedding': embedding,
        'message': message,
      });

    print('RAG message and chat data added successfully');
  } catch (e) {
    print('Error adding RAG message to database: $e');
  }
}

/*
  Adds a message to the supabase Database.
  Input:
    - String person  : The name of the person chatted with
    - String sender  : The sender of the message, either 'user' or 'bot'
    - String message : The contens of the message as a String
  Output:
    - void
*/
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

    print('Message and chat data added successfully');
  } catch (e) {
    print('Error adding message to database: $e');
  }
}

Future<void> addPersonToDatabase(String person) async {
  String description = await prompt_gen.generateDescription(person);

  // Update or insert into 'chats'
    await supabase
      .from('chats')
      .upsert({
        'person': person,
        'description' : description
      });
}

/*
  Fetches the names of all chat members and returns them as a List
  Input:
    - none
  Output:
    - List<Map<String, dynamic>> chatData : with fields 'name' and 'msg_time'
*/
Future<List<Map<String, String?>>> fetchChatsData() async {
  try {
    final response = await supabase
      .from('chats')
      .select('person');

    // Convert each dynamic map to a Map<String, String>
    final List<Map<String, String?>> data = response.map((entry) {
      return {
        'name': entry['person']?.toString(),
        'image_path': null,
      };
    }).toList();

    return data;
  } catch (e) {
    print('Error fetching chats data: $e');
    return [];
  }
}

Future<String> fetchPersonDescription(String person) async {
  try {
    final response = await supabase
      .from('chats')
      .select('person, description')
      .eq('person', person);
    
    // Parse the response as a List of dynamic maps
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

    return data[0]['description'];

  }
  catch (e) {
    return "Keine Beschreibung vorhanden";
  }
}

/*
  Fetches all chat messages belonging to a single Person and returns them as a List
  Input:
    - String person : name of the person whose chat data should be fetched
  Output:
    - List<Map<String, String>> chatHistory : with fields 'sender' and 'message'. No null values allowed.
*/
Future<List<Map<String, String>>> fetchMessageHistory(String person) async {
  try {
    final response = await supabase
        .from('message_history')
        .select('sender, message')
        .eq('person', person);

    // Parse the response as a List of dynamic maps
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

    // Convert each dynamic map to a Map<String, String>
    final List<Map<String, String>> chatHistory = data.map((entry) {
      return {
        'sender': entry['sender']?.toString() ?? '',
        'message': entry['message']?.toString() ?? '',
      };
    }).toList();

    return chatHistory;
  } catch (e) {
    print('Error fetching message history for $person: $e');
    return [];
  }
}

Future <String> fetchAllRAGMessages(String person) async {
  try {
    final response = await supabase
      .from('rag_messages')
      .select('message')
      .eq('person', person);
    
    String msg_acc = "";

    for (Map<String, dynamic> msg in response) {
      msg_acc += msg['message'].toString() + ", ";
    }

    return msg_acc;
  }
  catch (e) {
    return "";
  }
}

Future<String> fetchClosestRAGMessages(String person, String msg) async {
  try {
    String closestMessages = "";
    
    List<double> embedding = await embedder.generateText(msg);

    // Fetch the data from the rag_messages table
    final response = await supabase
      .from('rag_messages')
      .select('embedding, message')
      .eq('person', person);

    List<Map<String, dynamic>> messagesWithSimilarity = [];

    // Process each message and its embedding
    for (Map<String, dynamic> entry in response) {
      // Ensure that 'embedding' is parsed as a List<double> if it's a string
      List<double> storedEmbedding = List<double>.from(jsonDecode(entry['embedding']));

      // Calculate cosine similarity between the input message embedding and stored message embedding
      double similarity = cosineSimilarity(embedding, storedEmbedding);

      // Add the message and its similarity to the list
      messagesWithSimilarity.add({
        'message': entry['message'],
        'similarity': similarity,
      });
    }

    // Sort the messages by similarity in descending order
    messagesWithSimilarity.sort((a, b) => b['similarity'].compareTo(a['similarity']));

    // Append the top 5 messages to the result string
    int count = 0;
    for (var entry in messagesWithSimilarity) {
      if (count >= 10 || count == messagesWithSimilarity.length) break;
      closestMessages += "${entry['message']}, ";
      count++;
    }

    return closestMessages;
  } catch (e) {
    print("An error occurred: $e");
    return "";
  }
}

// Function to calculate the cosine similarity between two vectors
double cosineSimilarity(List<double> vector1, List<double> vector2) {
  double dotProduct = 0.0;
  double norm1 = 0.0;
  double norm2 = 0.0;

  for (int i = 0; i < vector1.length; i++) {
    dotProduct += vector1[i] * vector2[i];
    norm1 += vector1[i] * vector1[i];
    norm2 += vector2[i] * vector2[i];
  }

  norm1 = sqrt(norm1);
  norm2 = sqrt(norm2);

  return dotProduct / (norm1 * norm2);
}

/*
  Deletes the chat_history of a specific person
  Input:
    - String person : name of the person whose chatHistory should be deleted
  Output:
    - void
*/
Future<void> deleteMessageHistory(String person) async {
  try {
    await supabase
      .from('message_history')
      .delete()
      .eq('person', person);
    
    print('Message history deleted for $person');
  } catch (e) {
    print('Error deleting message history for $person: $e');
  }
}

/*
  Deletes the entire Chat with a specific person, meaning all entries in chats, chat_history and rag_messages in the Database
  Input:
    - String person : name of the person whose Data should be deleted
  Output:
    - void
*/
Future<void> deleteChat(String person) async {
  try {
    // Delete chat from 'message_history'
    await deleteMessageHistory(person);

    // Delete RAG messages
    await supabase
      .from('rag_messages')
      .delete()
      .eq('person', person);

    // Delete from 'chats'
    await supabase
      .from('chats')
      .delete()
      .eq('person', person);

    print('Chat data deleted for $person');
  } catch (e) {
    print('Error deleting chat data for $person: $e');
  }
}