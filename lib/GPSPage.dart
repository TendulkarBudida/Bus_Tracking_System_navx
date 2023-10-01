import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
// import 'package:flutter_background/flutter_background.dart';
import 'package:http/http.dart' as http;
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'dart:async';
// import 'dart:io';

import 'main.dart';

class GPSPage extends StatefulWidget {
  const GPSPage({super.key});

  @override
  State<GPSPage> createState() => _GPSPageState();
}

class _GPSPageState extends State<GPSPage> {
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  LocationData? _userLocation;

  String uri = "https://rarely-premium-owl.ngrok-free.app/NAVEX/insert.php";
  bool isBusActive = false;
  bool willContinueRequest = true;
  double fontMainSize = deviceWidth * 0.075;

  Future<void> _getUserLocation(Timer t) async {
    Location location = Location();

    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        t.cancel();
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        t.cancel();
        return;
      }
    }

    var locationData = await location.getLocation();
    setState(() {
      _userLocation = locationData;
    });
  }

  Future<void> insertRecord() async {
    if (!isBusActive) {
      if (willContinueRequest) {
        final res = await http.post(Uri.parse(uri), body: {
          "busActive": '$isBusActive',
          "reg": busReg.text,
          "route": busRoute.text,
          "latitude": '${_userLocation?.latitude}',
          "longitude": '${_userLocation?.longitude}',
        });
        willContinueRequest = false;
      }
      print("Data sending is currently stopped.");
      return;
    }
    willContinueRequest = true;

    try {
      // String uri = "https://rarely-premium-owl.ngrok-free.app/routrrloc/insertdata.php";

      final res = await http.post(Uri.parse(uri), body: {
        "busActive": '$isBusActive',
        "reg": busReg.text,
        "route": busRoute.text,
        "latitude": '${_userLocation?.latitude}',
        "longitude": '${_userLocation?.longitude}',
      });

      var response = json.decode(res.body);
      if(response["success"] == "true") {
        print("Record Inserted");
      } else {
        print("Record issue");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorMain,
        title: const Text("NavX Drive", style: TextStyle(
          color: Colors.white70
        ),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getGPSswitch(), SizedBox(height: paddingMain,),
            getGPS(),
          ],
        ),
      )
    );
  }

  Widget getGPS() {
    return Column(
      verticalDirection: VerticalDirection.up,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
          ),
          onPressed: () {
            // while (true) {
            //   _getUserLocation();
            //   print('Your latitude: ${_userLocation?.latitude}');
            //   print('Your longitude: ${_userLocation?.longitude}');
            //   sleep(const Duration(seconds: 5));
            // }
            Timer t = Timer(const Duration(seconds: 1), () {});
            _getUserLocation(t);
            Timer.periodic(const Duration(seconds: 5), (Timer t) {
              _getUserLocation(t);
              print('Your latitude: ${_userLocation?.latitude}');
              print('Your longitude: ${_userLocation?.longitude}');

              //willContinueRequest == true ? insertRecord() : {} ;
              insertRecord();
            });
          },
          child: const Text("GPS Locator"),
        ),
        const SizedBox(height: 25),
        // Display latitude & longitude
        Container(
          height: deviceHeight * 0.2,
          width: deviceWidth * 0.9,
          alignment: Alignment.centerLeft,
          child: _userLocation != null ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Latitude: ${_userLocation?.latitude}', style: TextStyle(
                  fontSize: fontMainSize
              )),
              const SizedBox(height: 10),
              Text('Longitude: ${_userLocation?.longitude}', style: TextStyle(
                  fontSize: fontMainSize
              ),)
            ],
          ) : const Text('Please enable location service and grant permission',
            style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
        ),
      ],
    );
  }

  Widget getGPSswitch() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(paddingMain),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Bus Status: ", style: TextStyle(fontSize: fontMainSize),), Spacer(),
            LiteRollingSwitch(
              value: false,
              textOn: "ON",
              textOff: "OFF",
              textOnColor: Colors.white70,
              textOffColor: Colors.white70,
              animationDuration: const Duration(milliseconds: 200),
              colorOn: Colors.blueGrey.shade900,
              colorOff: Colors.grey,
              iconOn: Icons.cloud_done_sharp,
              iconOff: Icons.bus_alert_outlined,
              textSize: 21,
              onChanged: (bool position) {
                print("The button is $position");
                isBusActive = position;
              },
              onDoubleTap: () {},
              onTap: () {},
              onSwipe: () {},
            ),
          ],
        ),
      ),
    );
  }
}