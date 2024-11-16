import 'package:flutter/material.dart';
import 'whatsapp_chat.dart';
import 'settings_drawer.dart';

List<Map<String, String?>> chatData = [
  {"name": "Person 1", "imagePath": null},
  {"name": "Person 2", "imagePath": null},
];

Map<String, List<Map<String, String>>> globalMessages= {
  "Person 1": [],
  "Person 2": []
};

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      drawer: ChatListDrawer(chatData: chatData),
      endDrawer: SettingsDrawer(),
      body: ListView.builder(
        itemCount: chatData.length,
        itemBuilder: (context, index) {
          return Container(
            height: 80, // Set a minimum height for each entry
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                radius: 30, // Increase the radius for a larger avatar
                backgroundColor: Colors.grey[400],
                backgroundImage: chatData[index]['imagePath'] != null
                    ? AssetImage(chatData[index]['imagePath']!)
                    : null,
                child: chatData[index]['imagePath'] == null
                    ? Icon(Icons.person, color: Colors.white, size: 30) // Adjust icon size
                    : null,
              ),
              title: Text(
                chatData[index]['name'] ?? 'Unknown',
                style: TextStyle(fontSize: 18), // Increase font size if needed
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WhatsAppChat(chatName: chatData[index]['name'] ?? 'Unknown',
                                                      globalMessageList : globalMessages),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            chatData.add({
              "name": "New Chat ${chatData.length + 1}",
              "imagePath": null,
            });
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ChatListDrawer extends StatelessWidget {
  final List<Map<String, String?>> chatData;

  ChatListDrawer({required this.chatData});

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
          ...chatData.map((chat) => Container(
            height: 80, // Set a minimum height for each entry in the drawer
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[400],
                backgroundImage: chat['imagePath'] != null
                    ? AssetImage(chat['imagePath']!)
                    : null,
                child: chat['imagePath'] == null
                    ? Icon(Icons.person, color: Colors.white, size: 30)
                    : null,
              ),
              title: Text(
                chat['name'] ?? 'Unknown',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WhatsAppChat(chatName: chat['name'] ?? 'Unknown',
                                                      globalMessageList : globalMessages),
                  ),
                );
              },
            ),
          )),
        ],
      ),
    );
  }
}
