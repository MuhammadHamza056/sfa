import 'package:flutter/material.dart';

class CustomLayoutBuilder extends StatefulWidget {
  final Widget? mobileScreen, tabletScreen, desktopScreen;
  const CustomLayoutBuilder(
      {super.key, this.mobileScreen, this.tabletScreen, this.desktopScreen});

  @override
  State<CustomLayoutBuilder> createState() => _CustomLayoutBuilderState();
}

class _CustomLayoutBuilderState extends State<CustomLayoutBuilder> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 850) {
          return widget.mobileScreen ?? const SizedBox();
        } else if (constraints.maxWidth > 850 && constraints.maxWidth <= 1100) {
          return widget.tabletScreen ?? const SizedBox();
        } else {
          return widget.desktopScreen ?? const SizedBox();
        }
      },
    );
  }
}
