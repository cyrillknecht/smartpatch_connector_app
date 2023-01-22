/// The app home page with buttons to connect, disconnect, open the Thingsboard UI
/// and go to the Settings page.

import 'package:flutter/material.dart';
import 'package:smartpatch_connector_app/functionality/default_settings.dart';
import 'package:smartpatch_connector_app/functionality/functionality.dart';
import 'package:smartpatch_connector_app/pages/settings_page.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pages_export.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(title),
            leading: GestureDetector(
              onTap: () => settingsButton(context),
              child: const Icon(Icons.settings),
            )),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                    onPressed: () => connectButton(context),
                    child: const Text('connect')),
                ElevatedButton(
                    onPressed: () => disconnectButton(context),
                    child: const Text('disconnect')),
                const ElevatedButton(
                    onPressed: goToThingsboardButton,
                    child: Text('Go to Patient-Data Platform'))
              ]),
        )));
  }
}

/// Navigates to the [settings_page].
void settingsButton(context) async {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => const SettingsPage(title: 'Settings Page')),
  );
}

/// Navigates to the [disconnect_page] after updating the settings
/// and fetching a list of patients.
void disconnectButton(context) async {
  await updateSettings();
  var patientData = await getPatientList();
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) =>
            DisconnectPage(title: 'Disconnect Page', patientData: patientData)),
  );
}

/// Navigates to the [connect_page] after updating the settings
/// and fetchings a list of patients.
void connectButton(context) async {
  await updateSettings();
  var patientData = await getPatientList();
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) =>
            ConnectPage(title: 'Connect Page', patientData: patientData)),
  );
}

/// Opens an in-app browser window with the Thingsboard UI.
goToThingsboardButton() async {
  updateSettings();
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

/// Updates all app settings from SharedPreferences.
updateSettings() async {
  var urlSetting = await getStringValueSharedPreferences('url');
  if (urlSetting != null && urlSetting != '') {
    ipAddress = urlSetting;
    url = 'http://' + urlSetting + ':8080/';
  }
  var usernameSetting = await getStringValueSharedPreferences('username');
  if (usernameSetting != null && usernameSetting != '') {
    user = usernameSetting;
  }
  var passwordSetting = await getStringValueSharedPreferences('password');
  if (passwordSetting != null && passwordSetting != '') {
    password = passwordSetting;
  }
  var maxPatientsSetting = await getIntValueSharedPreferences('maxPatients');
  if (maxPatientsSetting != null && maxPatientsSetting != 0) {
    maxPatients = maxPatientsSetting;
  }
}

/// Returns a current dict of patients with their connected MAC address from the Thingsboard database.
Future<Map<String, String>> getPatientList() async {
  Map<String, String> deviceData = {};
  try {
    // Create instance of ThingsBoard API Client
    var tbClient = ThingsboardClient(url);

    // Perform login with default Tenant Administrator credentials
    await tbClient.login(LoginRequest(user, password));

    var pageLink = PageLink(maxPatients);
    PageData<Device> patients;
    do {
      // Fetch tenant patients using current page link
      patients = await tbClient
          .getDeviceService()
          .getTenantDevices(pageLink, type: deviceType);
      for (var patient in patients.data) {
        var deviceAttribute = await tbClient
            .getAttributeService()
            .getAttributeKvEntries(patient.id!, ['Mac-Address']);
        dynamic macAddress;
        if (deviceAttribute.isEmpty) {
          macAddress = 'no mac-address found';
        } else {
          macAddress = deviceAttribute[0].getValue();
        }
        deviceData[patient.name] = macAddress;
        pageLink = pageLink.nextPageLink();
      }
    } while (patients.hasNext);

    // Finally perform logout to clear credentials
    tbClient.logout();
  } catch (e, s) {
    print('Error: $e');
    print('Stack: $s');
  }
  deviceData['Please select a patient'] = 'not a patient';
  return deviceData;
}
