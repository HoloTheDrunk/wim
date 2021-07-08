import 'dart:convert';
import 'package:http/http.dart' as http;

Future<int> lowestSellOrder(String itemSet) async {
  // curl request
  var res = await http.get(
    Uri.parse('https://api.warframe.market/v1/items/$itemSet/orders'),
    headers: {'accept': 'application/json', 'platform': 'pc'},
  );

  // Error handling
  if (res.statusCode != 200)
    throw Exception('http.get error: statusCode= ${res.statusCode}');

  // TODO: find the lowest price by someone online
  final data = jsonDecode(res.body);

  num minPlat = 9999;

  for (int i = 1; i < data['payload']['orders'].length; i++) {
    if (data['payload']['orders'][i]['order_type'] == "sell") {
      num price = data['payload']['orders'][i]['platinum'];
      if (data['payload']['orders'][i]['user']['status'] == "ingame" && price < minPlat) {
        minPlat = price;
      }
    }
  }

  return minPlat.toInt();
}

