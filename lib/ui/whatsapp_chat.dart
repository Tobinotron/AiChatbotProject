import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_drawer.dart';
import 'package:webcrawler/helpers/list_compare.dart' as list_compare;
import 'package:webcrawler/helpers/prompt_generator.dart' as prompt_gen;
import 'package:webcrawler/helpers/database.dart' as database;

class WhatsAppChat extends StatefulWidget {
  final String chatName;
  final Map<String, List<Map<String, String>>> globalMessageList;

  WhatsAppChat({required this.chatName, required this.globalMessageList});

  @override
  _WhatsAppChatState createState() => _WhatsAppChatState();
}

class _WhatsAppChatState extends State<WhatsAppChat> {
  List<Map<String, String>> messages = []; // To store the messages
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadFromGlobalMessages();
    // Initialize DB & Stopwords
    //initializeDatabase();
    //initializeStopwords();
    // Load messages when the widget is initialized
    //_loadMessages();
  }
  
  void loadFromGlobalMessages() {
    messages = widget.globalMessageList[widget.chatName]!;
  }

  void saveToGlobalMessages() {
    widget.globalMessageList[widget.chatName] = messages;
  }

  // Function to handle sending a message
  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      setState(() {
        messages.add({'sender': 'user', 'message': message});
      });
      _controller.clear();

      // Automatically respond after a short delay
      Future.delayed(Duration(seconds: 1), () async {
        await initializeDatabase();
        await initializeStopwords();
        String resources = await getHighestMatchingArticlesAsString(message);
        String responseLength = (await SharedPreferences.getInstance()).getString('responseLength') ?? 'Kurz';
        String response = await prompt_gen.generateResponse(resources, message, responseLength);
        response = utf8.decode(latin1.encode(response));
        setState(() {
          messages.add({'sender': 'bot', 'message': response});
        });
        saveToGlobalMessages();
      });
    }
  }

  // Function to load messages for the current chat
  Future<void> _loadMessages() async {
    List<Map<String, String>> loadedMessages = await loadMessages(widget.chatName);
    setState(() {
      messages = loadedMessages;
    });
  }

  // Get the directory to store the JSON files
  Future<Directory> _getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // Get the file path based on chatName
  Future<File> _getChatFile(String chatName) async {
    final dir = await _getAppDocumentsDirectory();
    return File('${dir.path}/$chatName.json');
  }

  // Save the messages to a JSON file
  Future<void> saveMessages(String chatName, List<Map<String, String>> messages) async {
    final file = await _getChatFile(chatName);
    final jsonString = jsonEncode(messages);
    await file.writeAsString(jsonString);
  }

  // Load messages from a JSON file, or create an empty file if it doesn't exist
  Future<List<Map<String, String>>> loadMessages(String chatName) async {
    try {
      final file = await _getChatFile(chatName);

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(jsonString);
        // Convert dynamic list to List<Map<String, String>>
        return List<Map<String, String>>.from(
          jsonData.map((item) => Map<String, String>.from(item)),
        );
      } else {
        // If the file doesn't exist, create it with an empty list
        await file.writeAsString(jsonEncode([]));
        return [];
      }
    } catch (e) {
      // Handle any errors, and return an empty list if something goes wrong
      print('Error loading messages: $e');
      return [];
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
