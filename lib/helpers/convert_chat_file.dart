import 'package:webcrawler/apis/msg_database.dart' as db;
import 'dart:io';

/*
* TODO: Chatfile durchgehen und die unique Names im Chat returnen.
  Inputs: -chatFilePath... Pfad zur Chat-Datei im selben Format wie /assets/TestWhatsappChat.txt
  Return: List<String> aller Chat-Teilnehmer
  Wichtig: Die Nachrichten dass WhatsAppChats End-toEnd verschlüsselt sind sollen natürlich Ignoriert werden.
           Wenn die File vom falschen Format ist, soll null zurückgegeben werden ~T
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
* TODO: ChatFile soll nochmal durchgegangen werden und mit allen Nachrichten der Person 'name' soll "db.addToDatabase(name, message)" gecalled werden.
  Inputs: -chatFilePath... Pfad zur Chat-Datei im selben Format wie /assets/TestWhatsappChat.txt
          -name... Name der Person deren Nachrichten gespeichert werden sollen
  Wichtig: Die Nachrichten dass WhatsAppChats End-toEnd verschlüsselt sind sollen natürlich Ignoriert werden.
           Genau so sollen auch Nachrichten mit <Medien ausgeschlossen> als message ignoriert werden ~T
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
          db.addToDatabase(name, message);
          messageCount++;
        }
      }
    }
    print("Es wurden ${messageCount} Nachrichten von ${name} hinzugefügt.");
  } catch (e) {
    print("Fehler beim Verarbeiten der Datei: \$e");
  }
}
