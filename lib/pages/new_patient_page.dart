/// Page provides the possibility to add a new patient to [patientData]
/// and to the Thingsboard database.

import 'package:flutter/material.dart';
import 'package:smartpatch_connector_app/functionality/default_settings.dart';
import 'package:smartpatch_connector_app/functionality/functionality.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class AddNewPatientPage extends StatefulWidget {
  const AddNewPatientPage(
      {Key? key, required this.title, required this.patientData})
      : super(key: key);
  final String title;
  final Map<String, String>? patientData;

  @override
  State<AddNewPatientPage> createState() =>
      // ignore: no_logic_in_create_state
      _AddNewPatientPageState(patientData);
}

class _AddNewPatientPageState extends State<AddNewPatientPage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, String>? patientData;
  final _chosenName = TextEditingController();
  _AddNewPatientPageState(this.patientData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add new Patient'),
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
                  controller: _chosenName,
                  validator: (text) => formValidator(text, patientData),
                  decoration: const InputDecoration(
                      hintText: 'Max Muster', labelText: 'Name'),
                ),
                ElevatedButton(
                    onPressed: () =>
                        addNewPatientButton(context, _formKey, _chosenName),
                    child: const Text('Add New Patient')),
              ],
            ),
          )),
        ));
  }
}

/// Adds a new patient with [chosenName] to the Thingsboard database
/// and returns to [connect_page].
void addNewPatientButton(context, formKey, chosenName) async {
  if (formKey.currentState!.validate()) {
    await addNewPatient(chosenName.text);
    Navigator.pop(context, chosenName.text);
  }
}

/// Validates that [text] is a patient name.
dynamic formValidator(text, patientData) {
  if (text == null || text.isEmpty) {
    return 'Name is required';
  } else if (patientData![text] != null) {
    return 'Patient already exists';
  } else {
    return null;
  }
}

/// Adds a new patient with [patientName] to the thingsboard database
/// and sets his  macAddress attribute to disconnected.
Future<void> addNewPatient(patientName) async {
  try {
    // Create instance of ThingsBoard API Client
    var tbClient = ThingsboardClient(url);

    // Perform login with default Tenant Administrator credentials
    await tbClient.login(LoginRequest(user, password));
    // Construct device object
    Device? device = Device(patientName, deviceType);
    device.additionalInfo = {
      'description': 'Patient provided with SmartPatch Connector App.'
    };

    // Add device
    await tbClient
        .getDeviceService()
        .saveDevice(device, accessToken: patientName);

    // Construct Raw Data device object
    Device? deviceRaw = Device(patientName + ' Raw Data', 'Raw');
    device.additionalInfo = {
      'description': 'Patient provided with SmartPatch Connector App.'
    };

    // Add Raw Data device
    await tbClient
        .getDeviceService()
        .saveDevice(deviceRaw, accessToken: patientName + ' Raw Data');

    // Finally perform logout to clear credentials
    await tbClient.logout();
  } catch (e, s) {
    print('Error: $e');
    print('Stack: $s');
  }
  // Set the MAC Address to disconnected because patient does not have a SmartPatch yet
  disconnectSmartPatch(patientName, "disconnected");
}
