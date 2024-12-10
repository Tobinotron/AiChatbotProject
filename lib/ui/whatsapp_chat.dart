import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_drawer.dart';
import 'package:webcrawler/helpers/list_compare.dart' as list_compare;
import 'package:webcrawler/apis/prompt_generator.dart' as prompt_gen;
import 'package:webcrawler/helpers/database.dart' as database;
import 'package:webcrawler/apis/msg_database.dart' as db;

class WhatsAppChat extends StatefulWidget {
  final String chatName;

  WhatsAppChat({required this.chatName});

  @override
  _WhatsAppChatState createState() => _WhatsAppChatState();
}

class _WhatsAppChatState extends State<WhatsAppChat> {
  List<Map<String, String>> messages = []; // To store the messages
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChatMessages();
  }
  

  // Function to handle sending a message
  void _sendMessage(String message) async{
    if (message.isNotEmpty) {
      // Write message to Database
      await db.addMessageToDatabase(widget.chatName, 'user', message);
      setState(() {
        messages.add({'sender': 'user', 'message': message});
      });
      _controller.clear();

      // Automatically respond after a short delay
      Future.delayed(Duration(seconds: 1), () async {
        //await initializeDatabase();
        //await initializeStopwords();
        String person_desc = await db.fetchPersonDescription(widget.chatName);
        String rag_messages = await db.fetchClosestRAGMessages(widget.chatName, message);
        String responseLength = (await SharedPreferences.getInstance()).getString('responseLength') ?? 'Kurz';
        String response = await prompt_gen.generateResponse(rag_messages, message, responseLength, messages, person_desc);
        response = utf8.decode(latin1.encode(response));
        // Write response to database
        await db.addMessageToDatabase(widget.chatName, 'bot', response);
        setState(() {
          messages.add({'sender': 'bot', 'message': response});
        });
      });
    }
  }

  // Get the directory to store the JSON files
  Future<Directory> _getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  void _loadChatMessages() async {
    try {
      final fetchedMessages = await db.fetchMessageHistory(widget.chatName);
      setState(() {
        messages = fetchedMessages;
      });
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  // Method to load JSON data
  Future<void> initializeDatabase() async {
    try {
      String jsonString = await rootBundle.loadString('assets/articles.json');
      var jsonData = json.decode(jsonString);
      if (jsonData is List) {
        database.processedArticles = jsonData.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else {
            throw Exception('Item is not a Map<String, dynamic>');
          }
        }).toList();
      } else {
        throw Exception('Decoded JSON is not a List');
      }
      print("Loaded JSON: $jsonString");
    } catch (e) {
      print("Error loading JSON: ${e.toString()}");
    }
  }

  // Method to initialize stopwords from a JSON file
  Future<void> initializeStopwords() async {
    try {
      String jsonString = await rootBundle.loadString('assets/stopwords-de.json');
      var jsonData = json.decode(jsonString);
      if (jsonData is List) {
        database.stopwords = jsonData.cast<String>();
      } else {
        throw Exception('Decoded JSON is not a List of strings');
      }
      print("Loaded Stopwords: $jsonString");
    } catch (e) {
      print("Error loading stopwords: ${e.toString()}");
    }
  }

  Future<String> getHighestMatchingArticlesAsString(String message) async {
    return await list_compare.getHighestMatchingArticlesAsString(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: SettingsDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isUser = message['sender'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green[300] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _sendMessage(_controller.text);
                  },
                  child: Icon(Icons.send),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
