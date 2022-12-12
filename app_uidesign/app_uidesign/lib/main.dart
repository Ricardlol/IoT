import 'package:flutter/material.dart';
import 'package:app_uidesign/responsive/responsive_layout.dart';
import 'package:app_uidesign/responsive/mobile_body.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const ResponsiveLayout(
        mobileBody: MobileScaffold(),
      ),
    );
  }
}
