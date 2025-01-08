import 'package:flutter/material.dart';

// Funktionalität in home_page.dart

// UPDATE Emulator funkt, fehlt nur die convertChat Funktion, um überhaupt zu überprüfen,
// ob das File richtig benutzt wird.

// Falls der nicht funktioniert, in
// android\app\src\main\AndroidManifest.xml die Zeilen
// <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
// <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
// entfernen.
// Evt. in android\app\build.gradle die ndkVersion = "25.1.8937393" wieder auf "flutter.ndkVersion" setzen

class AddChatButton extends StatelessWidget {
  final VoidCallback onPressed;

  AddChatButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Color(int.parse("#25D366".substring(1, 7), radix: 16) + 0xFF000000),
      child: Icon(Icons.add),
    );
  }
}

class NameSelectionDialog extends StatelessWidget {
  final List<String> nameList;

  NameSelectionDialog({required this.nameList});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select a Person"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: nameList
              .map(
                (name) => ListTile(
              title: Text(name),
              onTap: () {
                // Return the selected name to the calling function
                Navigator.of(context).pop(name);
              },
            ),
          )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Dismiss the dialog without selecting a name
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
      ],
    );
  }
}