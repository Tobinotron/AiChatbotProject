import 'package:flutter/material.dart';
import 'whatsapp_chat.dart';
import 'settings_drawer.dart';
import 'add_chat_button.dart';  // Import the new widget
import 'package:file_picker/file_picker.dart'; // Add this to your pubspec.yaml dependencies
import 'package:webcrawler/helpers/convert_chat_file.dart' as chatConvert;
import 'package:webcrawler/apis/msg_database.dart' as db;

List<Map<String, String?>> chatData = [];

void testFunction() {
  print("Test function called!");
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() async {
    try {
      final fetchedChatData = await db.fetchChatsData();
      setState(() {
        chatData = fetchedChatData;
      });
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  // importChatFile() muss im _HomePageState sein
  Future<void> importChatFile() async {
    // Step 1: Pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;

      // Step 2: Validate and extract chat members
      List<String>? nameList = chatConvert.getChatMembers(filePath);

      if (nameList == null || nameList.isEmpty) {
        // Show error if file is invalid
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Invalid File"),
              content: Text("The selected file is not valid for import."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        return;
      }

      // Step 3: Show name selection popup
      String? selectedName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return NameSelectionDialog(nameList: nameList);
        },
      );

      if (selectedName != null) {
        // Step 4: Process the selected name and read messages
        chatConvert.readMessagesIntoDatabase(filePath, selectedName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Chat for $selectedName added successfully!")),
        );

        // Update the chat list
        setState(() {
          chatData.add({
            "name": selectedName,
            "imagePath": null,
            "msg_time": null,
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("replAI"),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(int.parse("#25D366".substring(1, 7), radix: 16) + 0xFF000000), // Custom color for the title text
        ),
        backgroundColor: Color(int.parse("#FFFFFF".substring(1, 7), radix: 16) + 0xFF000000),
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
      drawer: ChatListDrawer(chatData: chatData, loadChats: _loadChats,),
      endDrawer: SettingsDrawer(),
      body: ListView.builder(
        itemCount: chatData.length,
        itemBuilder: (context, index) {
          return Container(
            height: 80,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[400],
                backgroundImage: chatData[index]['imagePath'] != null
                    ? AssetImage(chatData[index]['imagePath']!)
                    : null,
                child: chatData[index]['imagePath'] == null
                    ? Icon(Icons.person, color: Colors.white, size: 30)
                    : null,
              ),
              title: Text(
                chatData[index]['name'] ?? 'Unknown',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WhatsAppChat(
                      chatName: chatData[index]['name'] ?? 'Unknown',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: AddChatButton(
        onPressed: importChatFile, // Pass the updated importChatFile method
      ),
    );
  }
}

class ChatListDrawer extends StatelessWidget {
  final List<Map<String, String?>> chatData;
  final VoidCallback loadChats;

  ChatListDrawer({required this.chatData, required this.loadChats});

  void _showDeleteOptions(BuildContext context, String person,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Löschen'),
          content: Text(
              'Möchten Sie nur den Nachrichtenverlauf oder den gesamten Chat löschen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmDelete(context, person, db.deleteMessageHistory, loadChats);
              },
              child: Text('Chatverlauf löschen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmDelete(context, person, db.deleteChat, loadChats);
              },
              child: Text('Gesamten Chat löschen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Abbrechen'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String person,
      Future<void> Function(String) deleteFunction,
      VoidCallback loadChats) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sind Sie sicher?'),
          content: Text('Diese Aktion kann nicht rückgängig gemacht werden.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close confirmation dialog
                await deleteFunction(person);
                loadChats();
              },
              child: Text('Löschen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 150, // Adjust the height as needed
            child: DrawerHeader(
              decoration: BoxDecoration(color: Color(int.parse("#25D366".substring(1, 7), radix: 16) + 0xFF000000)),
              margin: EdgeInsets.zero,
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chat oder Verlauf löschen',
                  style: TextStyle(
                      color: Colors.white, fontSize: 26), // Adjust font size
                ),
              ),
            ),
          ),
          ...chatData.map((chat) =>
              Container(
                height: 80,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
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
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      if (chat['name'] != null) {
                        _showDeleteOptions(context, chat['name']!);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WhatsAppChat(
                              chatName: chat['name'] ?? 'Unknown',
                            ),
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