import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_drawer.dart';
import 'package:webcrawler/apis/prompt_generator.dart' as prompt_gen;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName),
        backgroundColor: Color(int.parse("#FFFFFF".substring(1, 7), radix: 16) + 0xFF000000),
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
