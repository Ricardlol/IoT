import 'package:flutter/material.dart';
import 'package:app_uidesign/src/constants.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../api/api.dart';
import '../api/models/user.dart';

class MobileScaffold extends StatefulWidget {
  const MobileScaffold({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {

  final flutterReactiveBle = FlutterReactiveBle();
  String infoText = "No device connected";
  String dataText = "No data received";

  // init state
  void initState() {
    super.initState();

    bool isConnected = false;
    Uuid serviceId = Uuid.parse("0000700a-0000-1000-8000-00805f9b34fb");
    Uuid characteristicId = Uuid.parse("0000701a-0000-1000-8000-00805f9b34fb");

    String foundDeviceId = "D4:E1:FC:D0:D8:0A";

    // flutterReactiveBle.scanForDevices(withServices: [serviceId]).listen((scanResult) {
    //   print('Found device: ${scanResult}');
    //
    //   // connect to device
    //   flutterReactiveBle.connectToDevice(id: scanResult.id).listen((connectionState) {
    //     print('Connection state: $connectionState');
    //     isConnected = true;
    //     foundDeviceId = scanResult.id;
    //   });
    //
    // });

    // connect to device
    flutterReactiveBle.connectToDevice(
        id: foundDeviceId,
        servicesWithCharacteristicsToDiscover: {serviceId: [serviceId]},
      connectionTimeout: const Duration(seconds: 2),
    ).listen((connectionState) {
      print('Connection state: $connectionState');

      if (connectionState.connectionState == DeviceConnectionState.connected)
      {
        print('Connected to device: $foundDeviceId');
        final characteristic = QualifiedCharacteristic(serviceId: serviceId, characteristicId: characteristicId, deviceId: foundDeviceId);
        print("characteristic: $characteristic");

        flutterReactiveBle.subscribeToCharacteristic(characteristic).listen((data) {
          // code to handle incoming data
          print('Data: $data');
          setState(() {
            dataText = data.toString();
          });

          for (int i = 0; i < widget.user.sensors.length; i++) {
            widget.user.sensors[i].data = data[0].toDouble();
            Api().updateSensorData(widget.user.sensors[i]);
          }

        }, onError: (dynamic error) {
          // code to handle errors
          print('Error: $error');
          setState(() {
            infoText = error.toString();
          });
        });

      }

      setState(() {
        infoText = connectionState.connectionState.toString();
      });



    }, onError: (Object error) {
      print('Error: $error');
      setState(() {
        infoText = error.toString();
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: defaultBackgroundColor,
        appBar: myAppBar,
        drawer: myDrawer,
        //body: Padding(
        //  padding: const EdgeInsets.all(8.0),
        //  child: Column(
        //    children: [
        //      // first 4 boxes in grid
        //      AspectRatio(
        //        aspectRatio: 1,
        //        child: SizedBox(
        //          width: double.infinity,
        //          child: GridView.builder(
        //            itemCount: 4,
        //            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //                crossAxisCount: 2),
        //            itemBuilder: (context, index) {
        //              return MyBox();
        //            },
        //          ),
        //        ),
        //      ),
        //    ],
        //  ),
        //),

        body: Column(
          children: [
            Text(infoText),
            Expanded(
              child: buildGrid(),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

        ),

        );
  }

  Widget buildGrid(){
    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      children:  [
        buildCard("Glucose Levels", dataText, color: const Color.fromARGB(255, 236, 163, 153)),
        buildCard("Heart Rate",dataText, color: const Color.fromARGB(255, 142, 223, 217)),
        buildCard("Blood Oxygen Levels", dataText, color: const Color.fromARGB(255, 166, 148, 207)),
        buildCard("Arterial Pressure", dataText, color:  const Color.fromARGB(255, 132, 216, 135)),
      ],
    );
  }

  Widget buildCard(String title, String value, {Color? color}) {
    return Card(
      color: color ,
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 20,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
