import 'package:webcrawler/apis/msg_database.dart' as db;
import 'dart:io';

/*
  Processes the chat file and returns the names of all chat participants.  
  Input:  
    - String chatFilePath: Path to the chat file in the same format as /assets/TestWhatsappChat.txt  
  Returns:  
    - List<String>? names: Names of all chat participants; can be null if the file has an incorrect format.  
*/

List<String>? getChatMembers(String chatFilePath) {
  try {
    final chatFile = File(chatFilePath);
    final chatContent = chatFile.readAsStringSync();

    Set<String> names = {};
    final lines = chatContent.split(RegExp(r'[\r\n]+'));
    final regex = RegExp(r'\d{2}\.\d{2}\.\d{2}, \d{2}:\d{2} - (.*?):');

    for (var line in lines) {
      if (line.contains("Ende-zu-Ende-verschlüsselt")) {
        continue;
      }
      final match = regex.firstMatch(line);
      if (match != null) {
        final name = match.group(1)!.trim();
        if (name.isNotEmpty) {
          names.add(name);
        }
      }
    }

    List<String> nameList = names.isNotEmpty ? names.toList() : [];
    return nameList.isNotEmpty ? nameList : null;
  } catch (e) {
    return null;
  }
}

/*
  Iterates through the chat file and calls adds all messages of the given person to the Database.  
  Input:  
    - String chatFilePath: Path to the chat file in the same format as /assets/TestWhatsappChat.txt  
    - String name: Name of the person whose messages should be saved  
  Returns:  
    - void  
*/

void readMessagesIntoDatabase(String chatFilePath, String name) {
  try {
    final chatFile = File(chatFilePath);
    final chatContent = chatFile.readAsStringSync();

    int messageCount = 0;
    final lines = chatContent.split(RegExp(r'[\r\n]+'));
    final regex = RegExp(r'\d{2}\.\d{2}\.\d{2}, \d{2}:\d{2} - ' + RegExp.escape(name) + r': (.*)', caseSensitive: false);

    for (var line in lines) {
      if (line.contains("Ende-zu-Ende-verschlüsselt") || line.contains("<Medien ausgeschlossen>")) {
        continue;
      }
      final match = regex.firstMatch(line);
      if (match != null) {
        final message = match.group(1)?.trim();
        if (message != null && message.isNotEmpty) {
          db.addRAGToDatabase(name, message);
          messageCount++;
        }
      }
    }
    db.addPersonToDatabase(name);
    print("Es wurden ${messageCount} Nachrichten von ${name} hinzugefügt.");
  } catch (e) {
    print("Fehler beim Verarbeiten der Datei: \$e");
  }
}
