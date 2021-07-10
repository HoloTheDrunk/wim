import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:wim/main.dart';

import 'package:wim/set.dart';
import 'package:wim/api_access.dart';

class MainArea extends StatefulWidget {
  const MainArea({Key? key}) : super(key: key);

  @override
  _MainAreaState createState() => _MainAreaState();
}

class _MainAreaState extends State<MainArea> {
  String inputFile = new File('data/inventory.csv').readAsStringSync();

  bool refreshing = false;
  final refreshRate = const Duration(milliseconds: 350);
  late Timer refreshTimer;

  List<List<dynamic>> inventory = [];
  List<List<dynamic>> additionalItems = [];
  List<ItemSet> converted = [];

  TextEditingController addBoxController = TextEditingController();
  late FocusNode addBoxFocusNode;

  ItemSet itemToItemSet(List<dynamic> item) {
    return ItemSet(
      name: item[0],
      type: item[1],
      quantities: [item[2], item[3], item[4], item[5]].cast<int>(),
      componentCodes: item[6].toString(),
    );
  }

  @override
  void initState() {
    super.initState();
    addBoxFocusNode = FocusNode();
    inventory = [
      ...const CsvToListConverter()
          .convert(inputFile, fieldDelimiter: ',')
          .skip(1)
          .toList(),
      ...additionalItems
    ];

    for (List<dynamic> item in inventory) {
      if (item[2] + item[3] + item[4] + item[5] > 0) {
        converted.add(itemToItemSet(item));
      }
    }

    refreshTimer = Timer.periodic(
      refreshRate,
      (timer) {
        setState(
          () {
            // print(
            //     "${converted.map((itemSet) => itemSet.needsUpdating ? itemSet.name : "").toList()}");
            for (int i = 0; i < converted.length; i++) {
              if (converted[i].needsUpdating) {
                final Future<List<int>> futurePrices =
                    getAllImportantData('${toFileName(converted[i].name)}_set');
                futurePrices.then(
                  (values) {
                    converted[i].lowPrice = values[0];
                    converted[i].highPrice = values[1];
                    converted[i].weightedAvgPrice = values[2];
                  },
                );
                converted[i].needsUpdating = false;
                converted[i].lastUpdate = DateTime.now();
                break;
              }
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    addBoxFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        controller: addBoxController,
                        focusNode: addBoxFocusNode,
                        autofocus: true,
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
                                      additionalItems.add(itemSet);
                                      converted.add(itemToItemSet(itemSet));
                                      print(inventory.length);
                                      print(additionalItems);
                                    }
                                    break;
                                  }
                                }
                              }
                              addBoxController.clear();
                              addBoxFocusNode.requestFocus();
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
                child: Stack(
                  children: [
                    Padding(
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
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                          shape: MaterialStateProperty.all(CircleBorder()),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.save, color: Colors.white),
                        ),
                        onPressed: () {
                          setState(() {
                            saveInventory(inventory);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
