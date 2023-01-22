/// ### Default Settings for the SmartPatch Connector App.
import 'package:smartpatch_connector_app/functionality/functionality.dart';

// Changeable in-app via settings page.

/// Thingsboard server IP address
String ipAddress = '192.168.0.235';

/// Url to use with the Thingsboard API
String url = 'http://' + ipAddress + ':8080/';

/// Thingsboard server username
String user = 'tenant@thingsboard.org';

///Thingsboard server password
String password = 'tenant';

/// Maximum number of patients that get fetched from Thingsboard database
int maxPatients = 100;

// Only changeable in code.

/// Maximum number of patients that get fetched from Thingsboard database
int maxBasestations = 100;

/// Standard device type for patients
String deviceType = 'Patient';

//Globals

///List of Thingsboard device Ids for all Basestation devices
Future<dynamic> basestationIdList = getBasestationIdList();
