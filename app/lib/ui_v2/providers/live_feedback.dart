import 'package:flutter/material.dart';

/// Lets code outside a screen show a short message (for example "That did not go through") on whatever screen is open.
/// The app's root `MaterialApp` is given this key; without it (tests) nothing is shown.
final GlobalKey<ScaffoldMessengerState> uiV2MessengerKey = GlobalKey<ScaffoldMessengerState>();

void showLiveMessage(String text) {
  final messenger = uiV2MessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
}
