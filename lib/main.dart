import 'package:flutter/material.dart';
import 'package:webcrawler/list_compare.dart' as list_compare;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webcrawler/database.dart' as database;
import 'package:webcrawler/prompt_generator.dart' as prompt_gen;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('WhatsApp Chat'),
        ),
        body: WhatsAppChat(),
      ),
    );
  }
}

class WhatsAppChat extends StatefulWidget {
  @override
  _WhatsAppChatState createState() => _WhatsAppChatState();
}

class _WhatsAppChatState extends State<WhatsAppChat> {
  List<Map<String, String>> messages = []; // To store the messages
  TextEditingController _controller = TextEditingController();

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
        String response = await prompt_gen.generateResponse(resources, message);
        response = utf8.decode(latin1.encode(response));
        //var msg = await getHighestMatchingArticlesAsString(message);
        setState(() {
          //loadJsonData();
          messages.add({'sender': 'bot', 'message': response});
        });
      });
    }
  }
  
// Method to load JSON data
Future<void> initializeDatabase() async {
  try {
    // Load JSON string from assets
    String jsonString = await rootBundle.loadString('assets/articles.json');
    var jsonData = json.decode(jsonString);

    // Check if jsonData is a List and assign it directly
    if (jsonData is List) {
      // Directly assign the list of maps to processedArticles
      database.processedArticles = jsonData.map((item) {
        // Ensure that each item is a Map<String, dynamic>
        if (item is Map<String, dynamic>) {
          return item; // Return the item as is
        } else {
          throw Exception('Item is not a Map<String, dynamic>');
        }
      }).toList();
    } else {
      throw Exception('Decoded JSON is not a List');
    }

    // Optionally print the loaded JSON string for debugging
    print("Loaded JSON: $jsonString");
    
  } catch (e) {
    print("Error loading JSON: ${e.toString()}"); // Print error for debugging
  }
}

// Method to initialize stopwords from a JSON file
Future<void> initializeStopwords() async {
  try {
    // Load JSON string from assets
    String jsonString = await rootBundle.loadString('assets/stopwords-de.json');
    var jsonData = json.decode(jsonString);

    // Check if jsonData is a List and assign it directly
    if (jsonData is List) {
      // Directly assign the list of strings to database.stopwords
      database.stopwords = jsonData.cast<String>();
    } else {
      throw Exception('Decoded JSON is not a List of strings');
    }

    // Optionally print the loaded JSON string for debugging
    print("Loaded Stopwords: $jsonString");
  } catch (e) {
    print("Error loading stopwords: ${e.toString()}"); // Print error for debugging
  }
}

  Future<String> getHighestMatchingArticlesAsString(message) async {
    return await list_compare.getHighestMatchingArticlesAsString(message);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // This is where the messages will appear
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

        // Input field and Send button at the bottom
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Text input field
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

              // Send button
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
    );
  }
}
