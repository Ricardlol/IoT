import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return mobileBody;
      },
    );
  }
}
