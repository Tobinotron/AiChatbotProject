import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsDrawer extends StatefulWidget {
  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  String responseLength = 'Kurz'; // Default response length

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved response length from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      responseLength = prefs.getString('responseLength') ?? 'Kurz';
    });
  }

  // Save response length to SharedPreferences
  Future<void> _saveSettings(String length) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('responseLength', length);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 150, // Adjust the height as desired
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green[700],
              ),
              margin: EdgeInsets.zero,
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Einstellungen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26, // Adjust text size to fit the smaller header
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            title: Text("Antwortlänge"),
          ),
          RadioListTile<String>(
            title: Text('Kurz'),
            value: 'Kurz',
            groupValue: responseLength,
            onChanged: (value) {
              setState(() {
                responseLength = value!;
              });
              _saveSettings(value!);
            },
          ),
          RadioListTile<String>(
            title: Text('Mittel'),
            value: 'Mittel',
            groupValue: responseLength,
            onChanged: (value) {
              setState(() {
                responseLength = value!;
              });
              _saveSettings(value!);
            },
          ),
          RadioListTile<String>(
            title: Text('Lang'),
            value: 'Lang',
            groupValue: responseLength,
            onChanged: (value) {
              setState(() {
                responseLength = value!;
              });
              _saveSettings(value!);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("Über die App"),
            onTap: () => _showDialog(context, 'Über die App', 'Diese Chatbot-App wurde entwickelt, um einer Person nachzuahmen.'),
          ),
          ListTile(
            leading: Icon(Icons.support),
            title: Text("Hilfe & Support"),
            onTap: () => _showDialog(context, 'Hilfe & Support', 'Kontaktieren Sie uns für Hilfe.'),
          ),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text("Kontakt"),
            onTap: () => _showDialog(context, 'Kontakt', 'E-Mail: support@example.com'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Abmelden"),
            onTap: () => _showDialog(context, 'Abmelden', 'Sind Sie sicher, dass Sie sich abmelden möchten?'),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever),
            title: Text("Account löschen"),
            onTap: () => _showDialog(context, 'Account löschen', 'Möchten Sie Ihren Account wirklich löschen?'),
          ),
        ],
      ),
    );
  }


  /// Function to show a dialog with a title and message.
  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Schließen'),
            ),
          ],
        );
      },
    );
  }
}
