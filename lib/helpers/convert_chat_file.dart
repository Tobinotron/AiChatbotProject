import 'package:webcrawler/helpers/msg_database.dart' as db;

/*
* TODO: Chatfile durchgehen und die unique Names im Chat returnen.
  Inputs: -chatFile... chatFile eingelesen als String im selben Format wie /assets/TestWhatsappChat.txt
  Return: List<String> aller Chat-Teilnehmer
  Wichtig: Die Nachrichten dass WhatsAppChats End-toEnd verschlüsselt sind sollen natürlich Ignoriert werden.
           Wenn die File vom Falschen Format ist soll null rückgegeben werden ~T
*/
List<String>? getChatMembers(String chatFile) {
  List<String> names = [];
  // ADD CODE HERE
  return names;
}

/*
* TODO: ChatFile soll nochmal durchgegangen werden und mit allen Nachrichten der Person 'name' soll "db.addToDatabase(name, message)" gecalled werden.
  Inputs: -chatFile... chatFile eingelesen als String im selben Format wie /assets/TestWhatsappChat.txt
          -name... Name der Person deren Nachrichten gespeichert werden sollen
  Wichtig: Die Nachrichten dass WhatsAppChats End-toEnd verschlüsselt sind sollen natürlich Ignoriert werden.
           Genau so sollen auch Nachrichten mit <Medien ausgeschlossen> als message ignoriert werden ~T
*/
void readMessagesIntoDatabase(String chatFile, String name) {
  // ADD CODE HERE
}