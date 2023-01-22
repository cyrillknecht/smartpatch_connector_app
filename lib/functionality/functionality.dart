/// Definition of all helper functions that get used in multiple pages.

import 'dart:convert';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'default_settings.dart';

/// Changes mac-address of [patientName] to [macAddress].
void changeMacAdress(patientName, macAddress) async {
  changeAttribute('Mac-Address', patientName, macAddress);
}

///Updates [attribute] of device with [accesstoken] in Thingsboard database to [attributeData].
void changeAttribute(attribute, accesstoken, attributeData) async {
  try {
    // initializing mqtt-client
    final client = MqttServerClient(ipAddress, accesstoken);

    // building the payload to publish
    var toPublish = "{'$attribute': '$attributeData'}";
    final builder = MqttClientPayloadBuilder();
    builder.addString(toPublish);

    // connecting to mqtt-broker with accesstoken
    await client.connect(accesstoken);

    // publishing the payload
    client.publishMessage(
        "v1/devices/me/attributes", MqttQos.exactlyOnce, builder.payload!);
  } catch (e, s) {
    print('Error: $e');
    print('Stack: $s');
  }
}

/// Changes the mac-address of [patientName] to "disconnected".
void disconnectSmartPatch(patientName, macAddress) async {
  //changing the chosen patient to disconnected
  changeMacAdress(patientName, "disconnected");
}

/// Posts an update message to the attribute [topic] containing [patientName]
/// and [macAddress] to all Basestations on Thingsboard.
void updateFlag(patientName, macAddress, topic) async {
  try {
    // Create instance of ThingsBoard API Client
    var tbClient = ThingsboardClient(url);

    // Perform login with default Tenant Administrator credentials
    await tbClient.login(LoginRequest(user, password));
    for (var updaterId in await basestationIdList) {
      tbClient.getAttributeService().saveDeviceAttributes(
          updaterId,
          "SHARED_SCOPE",
          jsonDecode('{"$topic": {"$patientName": "$macAddress"}}'));
    }
    // Finally perform logout to clear credentials
    tbClient.logout();
  } catch (e, s) {
    print('Error: $e');
    print('Stack: $s');
  }
}

/// Returns a String from [key] in SharedPreferences.
getStringValueSharedPreferences(key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String
  String? stringValue = prefs.getString(key);
  return stringValue;
}

/// Returns an Integer from [key] in SharedPreferences.
getIntValueSharedPreferences(key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return int
  int? intValue = prefs.getInt(key);
  return intValue;
}

/// Adds String [value] to [key] in SharedPreferences.
addStringToSharedPreferences(key, value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

/// Adds an integer [value] to [key] in SharedPreferences.
addIntToSharedPreferences(key, value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(key, value);
}

/// Return a List of Thingsboard device ids for all Basestations in the database.
getBasestationIdList() async {
  List idList = [];
  try {
    // Create instance of ThingsBoard API Client
    var tbClient = ThingsboardClient(url);

    // Perform login with default Tenant Administrator credentials
    await tbClient.login(LoginRequest(user, password));

    var pageLink = PageLink(maxBasestations);
    PageData<Device> basestations;
    do {
      // Fetch tenant basestations using current page link
      basestations = await tbClient
          .getDeviceService()
          .getTenantDevices(pageLink, type: 'Basestation');
      for (var basestation in basestations.data) {
        idList.add(basestation.id!.id);
        pageLink = pageLink.nextPageLink();
      }
    } while (basestations.hasNext);

    // Finally perform logout to clear credentials
    tbClient.logout();
  } catch (e, s) {
    print('Error: $e');
    print('Stack: $s');
  }
  return idList;
}
