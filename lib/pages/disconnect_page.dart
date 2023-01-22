/// Contains a possibility to scan a MAC address QR-code or select a patient
/// from the patient list to disconnect a SmartPatch.

import 'package:flutter/material.dart';
import 'package:smartpatch_connector_app/functionality/functionality.dart';
import 'pages_export.dart';

class DisconnectPage extends StatefulWidget {
  const DisconnectPage({Key? key, required this.title, this.patientData})
      : super(key: key);
  final String title;
  final Map<String, String>? patientData;

  @override
  // ignore: no_logic_in_create_state
  State<DisconnectPage> createState() => _DisconnectPageState(patientData);
}

class _DisconnectPageState extends State<DisconnectPage> {
  final Map<String, String>? patientData;
  final _formKey = GlobalKey<FormState>();
  String _selectedPatient = 'Please select a patient';
  String? _selectedMacAddress;

  _DisconnectPageState(this.patientData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Disconnect SmartPatch from Patient'),
        ),
        body: Form(
            key: _formKey,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          _selectedMacAddress = await scanQRCodeButton(context);
                        },
                        child: const Text('Scan QR-Code')),
                    const Center(child: Text('OR')),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      focusColor: Colors.white,
                      value: _selectedPatient,
                      validator: (value) => value == 'Please select a patient'
                          ? 'Please select a Patient to disconnect'
                          : null,
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: Colors.black,
                      items: patientData!.keys
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Center(
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      }).toList(),
                      hint: const Text(
                        "Choose an existing patient from the list or add a new patient",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedPatient = value!;
                        });
                      },
                    ),
                    ElevatedButton(
                        onPressed: () => disconnectSmartPatchButton(
                            context,
                            _formKey,
                            _selectedPatient,
                            _selectedMacAddress,
                            patientData),
                        child: const Text('Disconnect SmartPatch')),
                  ],
                ),
              ),
            )));
  }
}

/// Disconnects a SmartPatch associated with [selectedPatient] or [selectedMacAddress].
disconnectSmartPatchButton(
    context, formKey, selectedPatient, selectedMacAddress, patientData) {
  // Has the user selected a patient?
  if (selectedPatient != 'Please select a patient') {
    // Has he selected a patient and a mac-address?
    if (selectedMacAddress != null) {
      const snackBar = SnackBar(
          content: Text(
              'You chose a SmartPatch and a Patient to disconnect from. '
              'In case of a mismatch just the patient will be considered.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    if (formKey.currentState!.validate()) {
      disconnectSmartPatch(selectedPatient, patientData[selectedPatient]);
      // Indicating that there is an update on thingsboard.
      updateFlag(selectedPatient, patientData[selectedPatient], "Disconnected");
    }
  } else {
    for (var patient in patientData.keys) {
      if (patientData[patient] == selectedMacAddress) {
        disconnectSmartPatch(patient, selectedMacAddress);
        // Indicating that there is an update on thingsboard.
        updateFlag(patient, selectedMacAddress, "Disconnected");
      }
    }
  }
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => const SuccessPage(
              title: 'Success Page',
              previousAction: "disconnected",
            )),
  );
}
