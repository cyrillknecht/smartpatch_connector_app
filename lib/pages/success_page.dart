/// Page that gets shown after a connect or disconnect was sent.

import 'package:flutter/material.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage(
      {Key? key, required this.title, required this.previousAction})
      : super(key: key);
  final String title;
  final String previousAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Success'),
      ),
      body: Center(
        child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  const Icon(
                    IconData(0xe156, fontFamily: 'MaterialIcons'),
                    size: 100,
                  ),
                  Text(
                    "Congratulations, You sucessfully $previousAction a SmartPatch!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ]),
                ElevatedButton(
                    onPressed: () => returnToHomeButton(context),
                    child: const Text('Return to Home')),
              ],
            )),
      ),
    );
  }
}

/// Returns to the home page.
void returnToHomeButton(context) {
  Navigator.pop(context);
  Navigator.pop(context);
}
