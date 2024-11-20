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
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text("Response Length"),
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
            title: Text("More"),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("About App"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.support),
            title: Text("Help & Support"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text("Contact Us"),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Sign Out"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.delete_forever),
            title: Text("Delete Account"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
