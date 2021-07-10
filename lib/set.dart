import 'package:flutter/material.dart';
import 'package:wim/api_access.dart';
import 'package:wim/globals.dart';

class ItemSet extends StatefulWidget {
  final String name;
  final Type type;
  final List<int> quantities;
  final String componentCodes;
  bool needsUpdating;
  int lowPrice;
  int highPrice;
  int weightedAvgPrice;
  DateTime lastUpdate;

  ItemSet(
      {Key? key,
      @required name,
      @required type,
      @required quantities,
      String? componentCodes})
      : this.name = name,
        this.type = Type.values[type],
        this.quantities = quantities,
        this.componentCodes = componentCodes != null ? componentCodes : "000",
        this.needsUpdating = true,
        this.lowPrice = -1,
        this.highPrice = -1,
        this.weightedAvgPrice = -1,
        this.lastUpdate = DateTime.fromMillisecondsSinceEpoch(0),
        super(key: key);

  @override
  _ItemSetState createState() => _ItemSetState();
}

class _ItemSetState extends State<ItemSet> {
  void updatePrices(List<int> newPrices) {
    setState(
      () {
        widget.lowPrice = newPrices[0];
        widget.highPrice = newPrices[1];
        widget.weightedAvgPrice = newPrices[2];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<AssetImage> images = [];

    if (widget.type != Type.Warframe) {
      for (int i = 0; i < 3; i++) {
        images.add(
          AssetImage(
            "graphics/items/"
            "${ComponentCode.values[int.parse(widget.componentCodes[i])].toString().split('.')[1].toLowerCase()}"
            ".png",
          ),
        );
      }
    } else {
      images.add(AssetImage("graphics/items/neuroptics"));
      images.add(AssetImage("graphics/items/chassis"));
      images.add(AssetImage("graphics/items/systems"));
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.grey[800],
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Colors.lightBlueAccent,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            // Main blueprint
            flex: 1,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                ColorFiltered(
                  colorFilter: widget.quantities[0] == 0
                      ? greyscale
                      : ColorFilter.mode(Colors.transparent, BlendMode.color),
                  child: Image(
                    fit: BoxFit.fitHeight,
                    height: 128,
                    image: AssetImage(
                        'graphics/items/${toFileName(widget.name)}.png'),
                  ),
                ),
                qtyText(context, "x${widget.quantities[0]}", Colors.white),
                Positioned(
                  top: 35,
                  right: 80,
                  child: Column(
                    children: [
                      qtyButton(() => widget.quantities[0]++, "+1"),
                      qtyButton(() {
                        widget.quantities[0]--;
                        if (widget.quantities[0] < 0) widget.quantities[0] = 0;
                      }, "-1"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                children: [
                  Container(
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildItem(
                          context,
                          1,
                          widget.type == Type.Warframe
                              ? AssetImage("graphics/items/neuroptics.png")
                              : images[0],
                        ),
                        buildItem(
                          context,
                          2,
                          widget.type == Type.Warframe
                              ? AssetImage("graphics/items/chassis.png")
                              : images[1],
                        ),
                        buildItem(
                          context,
                          3,
                          widget.type == Type.Warframe
                              ? AssetImage("graphics/items/systems.png")
                              : images[2],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        child: Icon(Icons.refresh),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.lightBlueAccent),
                          shape: MaterialStateProperty.all(CircleBorder()),
                          fixedSize: MaterialStateProperty.all(Size(16, 16)),
                        ),
                        onPressed: () => {
                          setState(
                            () {
                              final curTime = DateTime.now();
                              // if (curTime.difference(refreshTime) >
                              //     Duration(milliseconds: 350)) {
                              //   refreshTime = curTime;
                              //   final Future<List<int>> futurePrices =
                              //       getAllImportantData(
                              //           '${toFileName(widget.name)}_set');
                              //   futurePrices
                              //       .then((value) => updatePrices(value));
                              // } else {
                              //   print("! Spam prevention. !");
                              // }
                              if (curTime.difference(widget.lastUpdate) >
                                  Duration(seconds: 5)) {
                                print("Updating ${widget.name}");
                                widget.needsUpdating = true;
                              }
                            },
                          ),
                        },
                      ),
                      buildCost(
                        context,
                        widget.lowPrice,
                        Icons.expand_more,
                        Colors.green,
                        null,
                      ),
                      buildCost(
                        context,
                        widget.highPrice,
                        Icons.expand_less,
                        Colors.red,
                        EdgeInsets.only(left: 4.0),
                      ),
                      buildCost(
                        context,
                        widget.weightedAvgPrice,
                        Icons.functions,
                        Colors.amber,
                        EdgeInsets.only(left: 4.0),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int qtyIndex, AssetImage image) {
    return Container(
      // Front part
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 2.0,
          )
        ],
        border: Border.all(
          color: Colors.grey,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey,
      ),

      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          ColorFiltered(
            colorFilter: widget.quantities[qtyIndex] == 0
                ? greyscale
                : ColorFilter.mode(Colors.transparent, BlendMode.color),
            child: Image(
              fit: BoxFit.scaleDown,
              height: 64,
              image: image,
            ),
          ),
          qtyText(context, "x${widget.quantities[qtyIndex]}", Colors.white),
          Positioned(
            right: 25,
            bottom: 5,
            child: Column(
              children: [
                qtyButton(() => widget.quantities[qtyIndex]++, "+1"),
                qtyButton(() {
                  widget.quantities[qtyIndex]--;
                  if (widget.quantities[qtyIndex] < 0)
                    widget.quantities[qtyIndex] = 0;
                }, "-1"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget qtyButton(var function, String text) {
    return ElevatedButton(
      child: qtyText(context, text, Colors.white),
      onPressed: () {
        setState(
          () {
            function();
          },
        );
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        shape: MaterialStateProperty.all(CircleBorder()),
        shadowColor: MaterialStateProperty.all(Colors.grey),
      ),
    );
  }

  Text qtyText(BuildContext context, String text, Color? color) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? Colors.white,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 2.0,
          )
        ],
      ),
    );
  }

  Widget buildCost(
    BuildContext context,
    int price,
    IconData? overlay,
    Color? color,
    EdgeInsetsGeometry? padding,
  ) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0),
      child: Row(
        children: [
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Image(
                image: AssetImage("graphics/platinum.png"),
                height: 16,
              ),
              Opacity(
                opacity: 0.75,
                child: Icon(
                  overlay,
                  color: color ?? Colors.white,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              price == -1 ? "???" : price.toString(),
              style: TextStyle(
                color: color ?? Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum Type {
  Warframe,
  Primary,
  Secondary,
  Sentinel,
}

enum ComponentCode {
  None,
  Barrel,
  Blade,
  Receiver,
  Stock,
  Handle,
}

List<int> intToList(int n) {
  List<int> res = [];
  while (n > 0) {
    res.add(n % 10);
    n ~/= 10;
  }
  return res;
}

String toFileName(String name) {
  return name.toLowerCase().replaceAll(' ', '_');
}
