import 'dart:core';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:simple_shadow/simple_shadow.dart';
import 'package:csv/csv.dart';

import 'package:wim/main_area.dart';

void main() {
  runApp(MyApp());
}

void saveInventory(List<List<dynamic>> inventory) {
  final output = new File('data/inventory.csv')
      .openWrite(encoding: ascii, mode: FileMode.write);
  output.write(ListToCsvConverter().convert(inventory));
  output.close();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wim',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: Wim(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Wim extends StatefulWidget {
  @override
  _WimState createState() => _WimState();
//_RandomWordsState createState() => _RandomWordsState();
}

class _WimState extends State<Wim> {
  String setName = "";
  List<int> setQties = [0, 0, 0, 0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        verticalDirection: VerticalDirection.up,
        children: [
          Expanded(
            child: MainArea(),
          ),
          buildAppBar(context),
        ],
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blueGrey[900], boxShadow: [
        BoxShadow(
          blurRadius: 4.0,
        ),
      ]),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 12.0, top: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 32.0),
                  child: SimpleShadow(
                    opacity: 0.6,
                    color: Colors.lightBlueAccent,
                    offset: Offset(0, 0),
                    sigma: 2,
                    child: Image(
                      image: AssetImage('graphics/warframe_logo.png'),
                      height: 64,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: SimpleShadow(
                    opacity: 0.6,
                    color: Colors.amber,
                    offset: Offset(0, 0),
                    sigma: 2,
                    child: Image(
                      image: AssetImage('graphics/section_items.png'),
                      height: 64,
                      width: 64,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Stack(
                    children: [
                      SimpleShadow(
                        opacity: 0.6,
                        color: Colors.purpleAccent,
                        offset: Offset(0, 0),
                        sigma: 4,
                        child: Image(
                          image: AssetImage('graphics/section_rivens.png'),
                          height: 64,
                          width: 64,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      Image(
                        image: AssetImage('graphics/wip.png'),
                        height: 64,
                        width: 64,
                        fit: BoxFit.fitHeight,
                      )
                    ],
                  ),
                ),
              ],
            ),
            Center(
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  ":)",
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
