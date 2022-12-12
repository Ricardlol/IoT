import 'package:flutter/material.dart';
import 'package:app_uidesign/constants.dart';

class MobileScaffold extends StatefulWidget {
  const MobileScaffold({Key? key}) : super(key: key);

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
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

        body: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          children: const [
            Card(
              color: Color.fromARGB(255, 236, 163, 153),
              child: Text(
                "Glucose Levels",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 20,
                ),
              ),
            ),
            Card(
              color: Color.fromARGB(255, 142, 223, 217),
              child: Text(
                "Heart Rate",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 20,
                ),
              ),
            ),
            Card(
              color: Color.fromARGB(255, 166, 148, 207),
              child: Text(
                "Blood Oxygen Levels",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 20,
                ),
              ),
            ),
            Card(
              color: Color.fromARGB(255, 132, 216, 135),
              child: Text(
                "Arterial Pressure",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ));
  }
}
