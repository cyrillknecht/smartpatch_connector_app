/// Allows user to set new Settings for the app.
/// Settings are applied immediately after changing them.

import 'package:flutter/material.dart';
import 'package:smartpatch_connector_app/functionality/functionality.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _chosenUrl = TextEditingController();
  final _chosenUsername = TextEditingController();
  final _chosenPassword = TextEditingController();
  final _chosenPatientMaximum = TextEditingController();
  final _chosenUpdaterId = TextEditingController();
  _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Form(
          key: _formKey,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextFormField(
                  controller: _chosenUrl,
                  validator: (text) => formValidator(text),
                  decoration: const InputDecoration(
                      hintText: 'thingsboard.cloud',
                      labelText: 'Thingsboard Server URL*'),
                ),
                TextFormField(
                  controller: _chosenUsername,
                  decoration: const InputDecoration(
                      hintText: 'tenant@thingsboard.org',
                      labelText: 'Thingsboard Username'),
                ),
                TextFormField(
                  controller: _chosenPassword,
                  decoration: const InputDecoration(
                      hintText: 'tenant', labelText: 'Thingsboard Password'),
                ),
                TextFormField(
                  controller: _chosenPatientMaximum,
                  decoration: const InputDecoration(
                      hintText: '100', labelText: 'Device Maximum'),
                ),
                ElevatedButton(
                    onPressed: () => updateSettingsButton(
                        context,
                        _formKey,
                        _chosenUrl,
                        _chosenUsername,
                        _chosenPassword,
                        _chosenPatientMaximum,
                        _chosenUpdaterId),
                    child: const Text('Apply Settings')),
              ],
            ),
          )),
        ));
  }
}

/// Updates the SharedPreferences for all Settings that were updated if they are valid.
void updateSettingsButton(context, formKey, chosenUrl, chosenUsername,
    chosenPassword, chosenPatientMaximum, chosenUpdaterId) async {
  if (formKey.currentState!.validate()) {
    await addStringToSharedPreferences('url', chosenUrl.text);
    if (chosenUsername.text != '') {
      addStringToSharedPreferences('username', chosenUsername.text);
    }
    if (chosenPassword.text != '') {
      addStringToSharedPreferences('password', chosenPassword.text);
    }
    if (chosenPatientMaximum.text != '') {
      addIntToSharedPreferences(
          'maxPatients', int.parse(chosenPatientMaximum.text));
    }
    Navigator.pop(context);
  }
}

/// Checks if [text] is a valid URL.
dynamic formValidator(text) {
  if (text == null || text.isEmpty) {
    return 'URL is required.';
  } else {
    return null;
  }
}
