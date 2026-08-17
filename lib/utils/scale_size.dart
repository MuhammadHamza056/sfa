import 'dart:math';
import 'package:flutter/material.dart';

class ScaleSize {
  static double textScaleFactor(BuildContext context,
      {double maxTextScaleFactor = 2}) {
    final width = MediaQuery.of(context).size.width;
    double val = (width / 1400) * maxTextScaleFactor;
    return max(1, min(val, maxTextScaleFactor));
  }

  static double getHorizontalWidth(
      {required BuildContext context, required double widthparam}) {
    // Define the maximum design width
    double maxDesignWidth = 1440.0;

    // Get the actual screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the dynamic size
    double dynamicSize = (widthparam / maxDesignWidth) * screenWidth;

    return dynamicSize;
  }

  static double getHorizontalWidthTab(
      {required BuildContext context, required double width}) {
    double maxDesignWidth = 960.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double dynamicSize = (width / maxDesignWidth) * screenWidth;

    return dynamicSize;
  }

  static double getVerticalHeight(
      {required BuildContext context, required double heightparam}) {
    // Get the actual screen height using MediaQuery
    double screenHeight = MediaQuery.of(context).size.height;
    double maxDesignHeight = 1024.0;
    // Calculate the dynamic size
    double dynamicSize = (heightparam / maxDesignHeight) * screenHeight;

    return dynamicSize;
  }

  static EdgeInsetsGeometry getPaddingPercentage(
      BuildContext context, double figmaPadding) {
    double containerWidth = MediaQuery.of(context).size.width;
    double paddingValue = (figmaPadding / containerWidth) * 100;
    return EdgeInsets.all(paddingValue);
  }

  static double getTextSizePercentage(
      BuildContext context, double figmaTextSize) {
    double containerWidth = MediaQuery.of(context).size.width;
    return (figmaTextSize / containerWidth) * 100;
  }
}
