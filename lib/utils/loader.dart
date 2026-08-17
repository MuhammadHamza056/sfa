import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Loader {
  static void showSuccess(String status) {
    Fluttertoast.showToast(
      msg: status,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static void showError(String error) {
    Fluttertoast.showToast(
      msg: error,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static void dismiss() {
    Fluttertoast.cancel();
  }
}

