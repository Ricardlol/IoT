import 'package:flutter/material.dart';
import 'package:app_uidesign/src/constants.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../api/api.dart';
import '../api/models/user.dart';
import '../ui/drawer.dart';

class MobileScaffold extends StatefulWidget {
  const MobileScaffold({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {

  final flutterReactiveBle = FlutterReactiveBle();

  String infoText = "No device connected";

  String glucoseData = "No data received";
  String heartbeatData = "No data received";
  String pressureData = "No data received";
  String oxygenInBloodData = "No data received";

  void resetSensorValues() {
    setState(() {
      glucoseData = "No data received";
      heartbeatData = "No data received";
      pressureData = "No data received";
      oxygenInBloodData = "No data received";
    });

    for (var sensor in widget.user.sensors) {
      sensor.data = 0;
      Api().updateSensorData(sensor);
    }
  }

  void UpdateSensorValue(String sensorType,  List<int> dataInt) {
    for (var sensor in widget.user.sensors) {
      // print("Sensor: " + sensor.sensor_type);
      if (sensor.sensor_type == sensorType) {
        //print("Sensor found: " + sensor.sensor_type);
        //print("Data: " + dataInt.toString());
        String data = dataInt[0].toString();
        sensor.data = dataInt[0].toDouble();
        String unitOfMeasurement = sensor.unit_of_measurement;

        Api().updateSensorData(sensor);

        setState(() {
          if (sensorType == "sugar_in_blood") {
            glucoseData = data + " " + unitOfMeasurement;
          } else if (sensorType == "heart_rate") {
            heartbeatData = data + " " + unitOfMeasurement;
          } else if (sensorType == "blood_presure") {
            pressureData = data + " " + unitOfMeasurement;
          } else if (sensorType == "oxygen_in_blood") {
            oxygenInBloodData = data + " " + unitOfMeasurement;
          }
        });
      }
    }
  }

  // init state
  void initState() {
    super.initState();
    resetSensorValues();
    bool isConnected = false;
    Uuid serviceId = Uuid.parse("0000700a-0000-1000-8000-00805f9b34fb");

    Uuid glucoseId = Uuid.parse("0000701a-0000-1000-8000-00805f9b34fb");
    Uuid heartbeatId = Uuid.parse("0000702a-0000-1000-8000-00805f9b34fb");
    Uuid pressureId = Uuid.parse("0000703a-0000-1000-8000-00805f9b34fb");
    Uuid oxygenInBloodId = Uuid.parse("0000704a-0000-1000-8000-00805f9b34fb");

    String foundDeviceId = "D4:E1:FC:D0:D8:0A";

    // Create QualifiedCharacteristic for each characteristic
    QualifiedCharacteristic glucoseCharacteristic = QualifiedCharacteristic(
      characteristicId: glucoseId,
      serviceId: serviceId,
      deviceId: foundDeviceId,
    );

    QualifiedCharacteristic heartbeatCharacteristic = QualifiedCharacteristic(
      characteristicId: heartbeatId,
      serviceId: serviceId,
      deviceId: foundDeviceId,
    );

    QualifiedCharacteristic pressureCharacteristic = QualifiedCharacteristic(
      characteristicId: pressureId,
      serviceId: serviceId,
      deviceId: foundDeviceId,
    );

    QualifiedCharacteristic oxygenInBloodCharacteristic = QualifiedCharacteristic(
      characteristicId: oxygenInBloodId,
      serviceId: serviceId,
      deviceId: foundDeviceId,
    );


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

        flutterReactiveBle.subscribeToCharacteristic(glucoseCharacteristic).listen((data)
        {
          print("Glucose data: " + data.toString());
          UpdateSensorValue("sugar_in_blood", data);
        }, onError: (dynamic error) {
          // code to handle errors
          print('Error: $error');
          setState(() {
            infoText = error.toString();
          });
        });

        flutterReactiveBle.subscribeToCharacteristic(heartbeatCharacteristic).listen((data)
        {
          print("Heartbeat data: " + data.toString());
          UpdateSensorValue("heart_rate", data);
        }, onError: (dynamic error) {
          // code to handle errors
          print('Error: $error');
          setState(() {
            infoText = error.toString();
          });
        });

        flutterReactiveBle.subscribeToCharacteristic(pressureCharacteristic).listen((data)
        {
          print("Pressure data: " + data.toString());
          UpdateSensorValue("blood_presure", data);
        }, onError: (dynamic error) {
          // code to handle errors
          print('Error: $error');
          setState(() {
            infoText = error.toString();
          });
        });

        flutterReactiveBle.subscribeToCharacteristic(oxygenInBloodCharacteristic).listen((data)
        {
          print("Oxygen in blood data: " + data.toString());
          UpdateSensorValue("oxygen_in_blood", data);
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
        drawer: MobileDrawer(user: widget.user),
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
            // Expanded(
            //   child: Column(
            //     children: [
            Container(
               padding: EdgeInsets.all(5),
               height: 300,
               child: buildDeviceInfoCard(infoText),
            ),
            Expanded(
              child:buildGrid(),
            ),
              // ],
              // )
            // ),
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
        buildCard("Glucose Levels", glucoseData, color: const Color.fromARGB(255, 236, 163, 153)),
        buildCard("Heart Rate", heartbeatData, color: const Color.fromARGB(255, 142, 223, 217)),
        buildCard("Blood Oxygen Levels", oxygenInBloodData, color: const Color.fromARGB(255, 166, 148, 207)),
        buildCard("Arterial Pressure", pressureData, color:  const Color.fromARGB(255, 132, 216, 135)),
      ],
    );
  }

  Widget buildDeviceInfoCard(String infoText) {
    return Card(
      color: Colors.blue ,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child:  Text(
              widget.user.full_name + "'s Device",
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 30,
              ),
            ),
          ),
          Column(
            children: [
          Container(
          padding: const EdgeInsets.all(10),
          child:  Row(
                  children: const <Widget>[
                    Icon(Icons.battery_full),
                    Text(
                      "Battery: 100%",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 20,
                      ),
                    ),
                  ]
              ),
          ),
              Container(
                padding: const EdgeInsets.all(10),
                child:  Row(
                    children: const <Widget>[
                      Icon(Icons.battery_full),
                      Text(
                        "Insuline Capacity: 100%",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                        ),
                      ),
                    ]
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child:  Text(
                  infoText,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
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
