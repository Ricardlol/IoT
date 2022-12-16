import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:app_uidesign/src/responsive/responsive_layout.dart';
import 'package:app_uidesign/src/responsive/mobile_body.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/api/api.dart';
import 'src/api/models/user.dart';
import 'src/ui/websocket.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  DartPluginRegistrant.ensureInitialized();

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
        mobileBody: const HomeScreen(),
      ),
    );
  }
}

final Future<String> _calculation = Api().login("633860821", "633860821");

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
        style: Theme.of(context).textTheme.headline2!,
    textAlign: TextAlign.center,
    child: FutureBuilder<String>(
      future: _calculation, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          return loadWebsocketBuilder(); // this returns the websocket widget
           // this returns the list of devices
        } else if (snapshot.hasError) {
          children = <Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${snapshot.error}'),
            ),
          ];
        } else {
          children = const <Widget>[
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            ),
          ];
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        );
      },
    ));
  }

  Widget loadWebsocketBuilder ()=>
      FutureBuilder<User>(
      future: Api().getCurrentUser(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          return Stack(
              children: [
                WebSocket(user: snapshot.data!),
                MobileScaffold(user: snapshot.data!),
              ]
          );
          // return WebSocket(user: snapshot.data!);
        } else if (snapshot.hasError) {
          children = <Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${snapshot.error}'),
            ),
          ];
        } else {
          children = const <Widget>[
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            ),
          ];
        }
        return DefaultTextStyle(style: Theme.of(context).textTheme.headline6!,
        child:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
          ),
        );
      }
  );
// create a future builder to check if the user is logged in
// if not, then redirect to the login page
// if yes, then redirect to the home page
//


}