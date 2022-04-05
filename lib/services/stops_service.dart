import 'dart:convert';

import 'package:http/http.dart';

import 'package:latlong2/latlong.dart';
import 'package:medirutas/models/busStop.dart';

class StopService {
  Future<List<Stop>> getStops() async {
    final response = await get(
        Uri.parse('https://pruebas-socket.herokuapp.com/coordenadas'));
    List data = jsonDecode(response.body);
    List<Stop> stops = [];

    for (var singleStop in data) {
      Stop stop = Stop.fromJson(singleStop);
      stops.add(stop);
    }
    return stops;
  }
}
