import 'dart:convert';
import 'package:http/http.dart' as http;

Future<http.Response> getItemData(String itemSet) async {
  // curl request
  return await http.get(
    Uri.parse('https://api.warframe.market/v1/items/$itemSet/orders'),
    headers: {'accept': 'application/json', 'platform': 'pc'},
  );
}

Future<List<int>> getAllImportantData(String itemSet) async {
  // curl request
  var res = await http.get(
    Uri.parse('https://api.warframe.market/v1/items/$itemSet/orders'),
    headers: {'accept': 'application/json', 'platform': 'pc'},
  );

  // Error handling
  if (res.statusCode != 200) {
    print(res);
    // throw Exception('http.get error: statusCode= ${res.statusCode}');
  }

  final data = jsonDecode(res.body);

  List<num> platValues = [];

  for (int i = 1; i < data['payload']['orders'].length; i++) {
    if (data['payload']['orders'][i]['order_type'] == "sell") {
      num price = data['payload']['orders'][i]['platinum'];
      if (data['payload']['orders'][i]['user']['status'] == "ingame") {
        platValues.add(price);
      }
    }
  }

  platValues.sort();

  num weightedAvgPlat = 0;
  num weight = 1;
  num weightSum = 0;

  for (int i = 0; i < platValues.length; i++) {
    weightedAvgPlat += platValues[i] * weight;
    weightSum += weight;
    weight *= 0.95;
  }

  print("Prices for $itemSet updated on ${DateTime.now()}.");

  return [
    platValues[0].toInt(),
    platValues[platValues.length - 1].toInt(),
    weightedAvgPlat ~/ weightSum,
  ];
}
