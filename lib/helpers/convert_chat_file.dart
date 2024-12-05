import 'package:webcrawler/apis/msg_database.dart' as db;
import 'dart:io';

/*
  Verarbeitet das chatFile und gibt die Namen aller Chat Teilnehmer zurück.
  Input:
    - String chatFilePath : Pfad zur Chat-Datei im selben Format wie /assets/TestWhatsappChat.txt
  Output:
    - List<String>? names : Namen aller Chat-Teilnehmer, kann null sein falls das File ein falsches Format hat.
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
  Geht das chatFile durch und ruft 'db.addRAGToDatabase(name, message)' für alle Nachrichten der gegebenen Person auf
  Input:
    - String chatFilePath : Pfad zur Chat-Datei im selben Format wie /assets/TestWhatsappChat.txt
    - String name : Name der Person deren Nachrichten gespeichert werden sollen
  Output:
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
    print("Es wurden ${messageCount} Nachrichten von ${name} hinzugefügt.");
  } catch (e) {
    print("Fehler beim Verarbeiten der Datei: \$e");
  }
}
