import 'package:flutter/material.dart';

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