import 'package:flutter/material.dart';
import 'package:webcrawler/list_compare.dart' as list_compare;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webcrawler/database.dart' as database;
import 'package:webcrawler/prompt_generator.dart' as prompt_gen;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Placeholder chat names (for display purposes only)
  List<String> chatNames = ["Placeholder Chat 1", "Placeholder Chat 2"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WhatsApp Chats"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
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
      drawer: ChatListDrawer(chatNames: chatNames),
      endDrawer: SettingsDrawer(),
      body: ListView.builder(
        itemCount: chatNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(chatNames[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WhatsAppChat(chatName: chatNames[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            chatNames.add("New Chat ${chatNames.length + 1}");
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ChatListDrawer extends StatelessWidget {
  final List<String> chatNames;

  ChatListDrawer({required this.chatNames});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Chat History', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ...chatNames.map((chatName) => ListTile(
            title: Text(chatName),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WhatsAppChat(chatName: chatName),
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}

class SettingsDrawer extends StatefulWidget {
  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  String responseLength = 'Short'; // Default response length

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved response length from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      responseLength = prefs.getString('responseLength') ?? 'Short';
    });
  }

  // Save response length to SharedPreferences
  Future<void> _saveSettings(String length) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('responseLength', length);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text("Response Length"),
          ),
          RadioListTile<String>(
            title: Text('Short'),
            value: 'Short',
            groupValue: responseLength,
            onChanged: (value) {
              setState(() {
                responseLength = value!;
              });
              _saveSettings(value!);
            },
          ),
          RadioListTile<String>(
            title: Text('Medium'),
            value: 'Medium',
            groupValue: responseLength,
            onChanged: (value) {
              setState(() {
                responseLength = value!;
              });
              _saveSettings(value!);
            },
          ),
          RadioListTile<String>(
            title: Text('Detailed'),
            value: 'Detailed',
            groupValue: responseLength,
            onChanged: (value) {
              setState(() {
                responseLength = value!;
              });
              _saveSettings(value!);
            },
          ),
          Divider(),
          ListTile(
            title: Text("More"),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("About App"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.support),
            title: Text("Help & Support"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text("Contact Us"),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Sign Out"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.delete_forever),
            title: Text("Delete Account"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class WhatsAppChat extends StatefulWidget {
  final String chatName;

  WhatsAppChat({required this.chatName});

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
        setState(() {
          messages.add({'sender': 'bot', 'message': response});
        });
      });
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
