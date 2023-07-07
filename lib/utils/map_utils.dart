import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:me_voy_usuario/models/route_response.dart';
import 'package:me_voy_usuario/models/stop.dart';

const mapboxAccessToken =
    'pk.eyJ1IjoiZWxpYXNkaWF6MTAwNSIsImEiOiJjbDUxdGpveGUwOHhzM2pwajZjNWVjaHYwIn0.aFD-rLHhe8R-vYYh3OYHKw';

class MapUtils {
  final baseUrl = 'https://api.mapbox.com/directions/v5';
  final _dio = Dio();
  PolylinePoints polylinePoints = PolylinePoints();

  Future<List<List<LatLng>>> createWalkingRoute(
      LatLng userLocation, List<Stop> stops, LatLng? destino) async {
    LatLng firstStopLocation = LatLng(stops[0].latitude, stops[0].longitude);
    List<LatLng> firstwalkingRouteLL =
        await fetchRoute(userLocation, firstStopLocation);
    if (destino == null) {
      return [firstwalkingRouteLL];
    } else {
      LatLng scndStopLocation = LatLng(stops[1].latitude, stops[1].longitude);
      List<LatLng> scndwalkingRouteLL =
          await fetchRoute(scndStopLocation, destino);
      return [firstwalkingRouteLL, scndwalkingRouteLL];
    }
  }

  Future<List<LatLng>> fetchRoute(LatLng point1, LatLng point2) async {
    var url =
        '$baseUrl/mapbox/walking/${point1.longitude},${point1.latitude};${point2.longitude},${point2.latitude}';
    final resp = await _dio.get(url, queryParameters: {
      'alternatives': 'false',
      'geometries': 'polyline6',
      'steps': 'false',
      'access_token': mapboxAccessToken,
      'language': 'es',
    });

    final data = RouteResponse.fromJson(resp.data);
    final geometry = data.routes[0].geometry;
    final points = polylinePoints.decodePolyline(geometry);

    return points
        .map((p) => LatLng(p.latitude / 10, p.longitude / 10))
        .toList();
  }
}
