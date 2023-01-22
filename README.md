# SmartPatch Connector App

## Quick overview
The **SmartPatch Connector App** is a crossplatform application designed to easily connect and disconnect SmartPatches from patients.
The app is available on iOs and Android. It is a part of the SmartPatch System.

To use the app on Android simply download its [**APK**](SmartPatch_Connector_App_v_1_0_0.apk) file from this repo to your Android phone and install it.

## Installation
### iOS
#### Test the App on iOS
To test the application on iOS, follow this [guide](https://medium.com/front-end-weekly/how-to-test-your-flutter-ios-app-on-your-ios-device-75924bfd75a8).
This is the only way to test the app on a real device on iOs without an [Apple Developer program](https://developer.apple.com/programs/) membership.
#### Release
If you want to release the app on iOS, use this [official guide](https://docs.flutter.dev/deployment/ios).


### Android
#### Beta Distribution
To use the  application on Android, download the [SmartPatch_Connector_App_v_1_0_0.apk](SmartPatch_Connector_App_v_1_0_0.apk) file to your Android phone and install it.
#### Release
If you want to officially release the app on Android, use this [official guide](https://docs.flutter.dev/deployment/android).

## Use the app
### Connect
Scan a SmartPatch QR code **and** select a patient from your patient list to map them to each other. You can also add a new patient if the patient to connect to is not already on the list. After connecting you shold now be see the sensor data for this  SmartPatch in the SmartPatch UI when selecting the patient.
This should always be done when a SmartPatch is getting attached to a patient.
### Disconnect
Scan a SmartPatch QR code **or** select a patient from your patient list to disconnect his currently connected SmartPatch. This should always be done when a SmartPatch is removed from a patient.

## Further documentation
For further documentation on the SmartPatch System consider looking at the code documentation. It can found in the `doc/api` directory of this repository. Please clone the repository and then open `index.html` in said repository.


## What is the SmartPatch System?
The SmartPatch System includes a SmartPatch for acquiring vital sensor data and a supporting ecosystem consisting of a [Basestation Software](https://gitlab.ethz.ch/pbl/hs2021/flagship-smart-patch-2021/base-station-v1) designed to acquire the Sensor Data on a Basestation device (Raspberry Pi) and publishing it to a Thingsboard Server.
Further it includes a [Thingsboard](https://thingsboard.io/) server setup to display the acquired data. And the [SmartPatch Connector App](https://gitlab.ethz.ch/pbl/hs2021/flagship-smart-patch-2021/connector-app-v1) available for iOS and Android, that makes it easy to connect SmartPatches and assign them to a patient.


