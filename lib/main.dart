import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:location/location.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:http/http.dart' as http;
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'dart:async';
import 'dart:io';

import 'GPSPage.dart';

// First get the FlutterView.
FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;

Size size = view.physicalSize / view.devicePixelRatio;
double deviceWidth = size.width;
double deviceHeight = size.height;

double paddingMain = deviceWidth * 0.05;
Color colorMain = Colors.blueGrey.shade900;

List<String> busTypeList = <String>['Petrol', 'Diesel', 'Electronic Vehicle', 'CNG'];

TextEditingController busReg = new TextEditingController();
TextEditingController busRoute = new TextEditingController();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: colorMain),
        appBarTheme: AppBarTheme(backgroundColor: colorMain),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'NavX Drive'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: colorMain,
        title: Text(widget.title, style: const TextStyle(
          color: Colors.white70,
        ),),
      ),
      body: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            putGIF(),
            getBusDetails(), SizedBox(height: paddingMain * 2),
            continueButton(),
          ],
        ),
      ),
    );
   }

  Widget putGIF() {
    return Image.asset(
      "images/bus_animation_gif.gif",
      width: deviceWidth - (2 * paddingMain),
    );
  }

  Widget getBusDetails() {
    String dropDownValue = busTypeList.first;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: paddingMain, right: paddingMain, top: paddingMain),
          child: TextFormField(
            controller: busReg,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Enter the Bus Registration Number')
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(paddingMain),
          child: TextFormField(
            controller: busRoute,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Enter the Bus Route Number')
            ),
          ),
        ),
        // DropdownButton(
        //   value: dropDownValue,
        //   icon: const Icon(Icons.arrow_drop_down),
        //   elevation: 4,
        //   //style: const TextStyle(color: ),
        //   underline: Container(height: 2),
        //   items: busTypeList.map<DropdownMenuItem<String>>((String value) {
        //     return DropdownMenuItem<String>(
        //       value: value,
        //       child: Text(value),
        //     );
        //   }).toList(),
        //   onChanged: (String? value) {
        //     setState(() {
        //       dropDownValue = value!;
        //     });
        //   }
        // )
      ],
    );
  }

  Widget continueButton() {
    return ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const GPSPage()//{return const Page2();}
              )
          );
        },
        child: Text("Continue")
    );
  }
}