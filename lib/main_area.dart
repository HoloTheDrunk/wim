import 'package:flutter/material.dart';

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:wim/set.dart';

class MainArea extends StatefulWidget {
  const MainArea({Key? key}) : super(key: key);

  @override
  _MainAreaState createState() => _MainAreaState();
}

class _MainAreaState extends State<MainArea> {
  String input = new File('data/inventory.csv').readAsStringSync();

  List<List<dynamic>> inventory = [];
  List<List<dynamic>> additionalItems = [];

  // const CsvToListConverter().convert(input, fieldDelimiter: ',');

  @override
  Widget build(BuildContext context) {
    inventory = [
      ...const CsvToListConverter().convert(input, fieldDelimiter: ','),
      ...additionalItems
    ];
    List<ItemSet> converted = [];
    for (List<dynamic> item in inventory) {
      //print("item#${item.hashCode}: $item | len:${item.length}");
      if (item[2] + item[3] + item[4] + item[5] > 0) {
        converted.add(
          ItemSet(
            name: item[0],
            type: item[1],
            quantities: [item[2], item[3], item[4], item[5]].cast<int>(),
            componentCodes: item[6].toString(),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
              boxShadow: [
                BoxShadow(
                  blurRadius: 4.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Center(
                          child: Text(
                            "Add a new set",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          labelText: 'Set name (e.g. "Rhino Prime")',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          fillColor: const Color(0x22AABBCC),
                          filled: true,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        onSubmitted: (String setName) {
                          setState(
                            () {
                              bool duplicate = false;
                              String lcName = setName.toLowerCase();
                              for (var itemSet in additionalItems) {
                                if (lcName ==
                                    itemSet[0].toString().toLowerCase()) {
                                  duplicate = true;
                                }
                              }
                              if (!duplicate) {
                                for (var itemSet in inventory) {
                                  if (lcName ==
                                      itemSet[0].toString().toLowerCase()) {
                                    for (var convertedSet in converted) {
                                      if (lcName ==
                                          convertedSet.name.toLowerCase()) {
                                        duplicate = true;
                                        break;
                                      }
                                    }
                                    if (!duplicate) {
                                      var newItemSet = itemSet;
                                      newItemSet[2] = 1;
                                      print(additionalItems);
                                      additionalItems.add(itemSet);
                                      print(additionalItems);
                                    }
                                    break;
                                  }
                                }
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      "Inquiries: Holo the Drunk#1757",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisExtent: 128,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    clipBehavior: Clip.none,
                    itemCount: converted.length,
                    itemBuilder: (BuildContext context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                            ),
                          ],
                        ),
                        child: converted[index],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
