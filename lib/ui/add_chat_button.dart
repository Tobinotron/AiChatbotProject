import 'package:flutter/material.dart';
import 'package:webcrawler/helpers/convert_chat_file.dart' as chatConvert;

class AddChatButton extends StatelessWidget {
  final VoidCallback onPressed;

  AddChatButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(Icons.add),
    );
  }
}

/*
  TODO: Das File Menu (mainly: Android) soll aufgehen und dem User soll die Möglichkeit gegeben werden, ein File upzuloaden.
  Mit der Methode chatConvert.getChatMembers(chatFile) wird eine List<String>? an Namen returned, wenn diese null ist == File nicht gültig
  Danach soll ein Pop-Up Screen aufgehen, bei dem Man auswählen kann welche Person man wählen möchte.
  Mit diesem Namen wird dann readMessagesIntoDatabase(String chatFile, String name) gecalled.

  WICHTIG: Ich weiß nicht ob es richtig ist, diese Methode hier drinnen (also im AddChatButton) zu callen! Ich weiß nämlich nicht ob es möglich
  sein wird, hier das Pop-Up zu machen. Ansonsten mach den Pop-Up Code in ner extra File und mach da die Methode drinnen. Ist dir überlassen :)
  Auch wichtig: Du musst nur diese Methode machen! Die beiden Methoden die gecalled werden sind nicht deine Responsibility ~T
*/
void importChatFile() {

  List<String>? nameList = chatConvert.getChatMembers("CHATFILE AS STRING HERE");
}