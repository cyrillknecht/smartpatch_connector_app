/// Contains options to scan a QR-code and select a patient from [patientData]
/// or to add a new patient to the Thingsboard database and to [patientData]
/// and connect a SmartPatch using the two selected values.

import 'package:flutter/material.dart';
import 'package:smartpatch_connector_app/functionality/functionality.dart';
import 'pages_export.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({Key? key, required this.title, required this.patientData})
      : super(key: key);
  final String title;
  final Map<String, String>? patientData;

  @override
  // ignore: no_logic_in_create_state
  State<ConnectPage> createState() => _ConnectPage(patientData);
}

class _ConnectPage extends State<ConnectPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPatient = 'Please select a patient';
  String? _selectedMacAddress;
  Map<String, String>? patientData;
  _ConnectPage(this.patientData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Connect SmartPatch to Patient'),
        ),
        body: Form(
            key: _formKey,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          _selectedMacAddress = await scanQRCodeButton(context);
                        },
                        child: const Text('Scan QR-Code')),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      focusColor: Colors.white,
                      value: _selectedPatient,
                      validator: (value) => value == 'Please select a patient'
                          ? 'Please select a Patient first'
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
                      onChanged: (String? value) {
                        setState(() {
                          _selectedPatient = value!;
                        });
                      },
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          var newPatient = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddNewPatientPage(
                                      patientData: patientData,
                                      title: 'Add New Patient Page',
                                    )),
                          );
                          if (newPatient != null) {
                            patientData![newPatient] = 'Newly created patient';
                            setState(() {
                              patientData;
                              _selectedPatient = newPatient;
                            });
                            final snackBar = SnackBar(
                                content: Text(
                                    'Succesfully added $newPatient to patient list!'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        child: const Text('Add New Patient')),
                    ElevatedButton(
                        onPressed: () {
                          connectSmartPatchButton(
                              context,
                              _formKey,
                              _selectedMacAddress,
                              _selectedPatient,
                              patientData);
                        },
                        child: const Text('Connect SmartPatch')),
                  ],
                ),
              ),
            )));
  }
}

/// Navigates to the [qr_scanner_page]. When the it returns, displays the selected
/// [macAddress].
Future<String?> scanQRCodeButton(context) async {
  String? macAddress = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const QRScannerPage()),
  );
  if (macAddress != null) {
    final snackBar = SnackBar(
        content: Text(
            'Succesfully scanned SmartPatch with MAC Address: $macAddress'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return macAddress;
  } else {
    const snackBar =
        SnackBar(content: Text("No MAC Address selected. Please scan again."));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return null;
  }
}

/// Connects a SmartPatch.
///
/// Connecting means that[selectedMacAddress] and [selectedPatient] are set as attribute
/// Connected for all Basestations in the Thingsboard database.
/// Additionally [selectedPatient] gets its attribute Mac-Address updated
/// to [selectedMacAddress] in the Thingsboard database.
connectSmartPatchButton(
    context, formKey, selectedMacAddress, selectedPatient, patientData) async {
  if (formKey.currentState!.validate()) {
    if (selectedMacAddress == null) {
      const snackBar =
          SnackBar(content: Text('Please scan SmartPatch QR-Code first.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      await connectSmartPatch(selectedPatient, selectedMacAddress, patientData);
      //indicating that there is an update on thingsboard
      updateFlag(selectedPatient, selectedMacAddress, "Connected");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const SuccessPage(
                  title: 'Success Page',
                  previousAction: "connected",
                )),
      );
    }
  }
}

/// Changes [patientName]'s  macaddress attribute on thingsboard to [macAddress].
/// First cleans up the patients previous connections.
Future<void> connectSmartPatch(String patientName, String macAddress,
    Map<String, String> patientData) async {
  //if a patient is already connected to the device, we must change his macaddress to disconnected
  if (patientData.containsValue(macAddress)) {
    for (var patient in patientData.keys) {
      if (patientData[patient] == macAddress) {
        disconnectSmartPatch(patient, macAddress);
      }
    }
  }

  /// changes the MAC address for the chosen patient
  changeMacAdress(patientName, macAddress);
}
