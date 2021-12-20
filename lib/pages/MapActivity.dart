import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:medirutas/helpers/cached_tile_provider.dart';

class MapActivity extends StatefulWidget {
  const MapActivity({Key? key}) : super(key: key);

  @override
  _MapActivityState createState() => _MapActivityState();
}

class _MapActivityState extends State<MapActivity> {
  @override
  void initState() {
    super.initState();

    //mueve el centro a la ultima ubicacion obtenida
    moveCenter();
  }

  late Position currentLocation;
  late StreamSubscription<Position> positionStream;
  final MapController mapController = MapController();

  //Lista de puntos
  List<LatLng> puntos = [];

  bool startStop = true;

  @override
  Widget build(BuildContext context) {
    //mapa de markers
    var markers = puntos.map((latlng) {
      return Marker(
        point: latlng,
        builder: (_) =>
            const Icon(Icons.circle, size: 15, color: Colors.blueAccent),
      );
    }).toList();

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        floatingActionButton: floatingActionButton(),
        body: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                  center: LatLng(0, -0), zoom: 18.0, minZoom: 16, maxZoom: 18),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'], tileProvider: const CachedTileProvider()),
                    
                MarkerLayerOptions(markers: markers),
              ],
            ),
            startStopButton()
          ],
        ));
  }

  //Boton para empezar/terminar el trazado
  startStopButton() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 50),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 5),
                    startStop
                        ? const Text(
                            'Empezar camino',
                            style: TextStyle(fontSize: 20),
                          )
                        : const Text(
                            'Finalizar camino',
                            style: TextStyle(fontSize: 20),
                          )
                  ],
                ),
              ),
              onPressed: () {
                startOrStop();
              }),
        ));
  }

  //Funcion que verifica si esta trackeando o no
  startOrStop() {
    if (startStop) {
      startTracking();
    } else {
      stopTracking();
    }
  }

  //Empezar tracking
  startTracking() {
    setState(() {
      startStop = false;

      positionStream = Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.bestForNavigation,
                  distanceFilter: 10))
          .listen((Position position) {
        mapController.move(
            LatLng(position.latitude, position.longitude), mapController.zoom);

        //modificar constantemente el centro del mapa
        setState(() {
          puntos.add(LatLng(position.latitude, position.longitude));

          // print('Ruta: $puntos');
        });
      });
    });
  }

  //finalizar ruta y detener el stream
  stopTracking() {
    setState(() {
      startStop = true;
      positionStream.cancel();
      // print('position stream canceled');

      //Mostrar dialogo
      showAlert();
    });
  }

  //Obtener ultima ubicacion del movil y ubicar en el centro
  moveCenter() async {
    Position? position = await Geolocator.getLastKnownPosition();
    mapController.move(LatLng(position!.latitude, position.longitude), 18);
  }

  //Mostrar Dialogo para guardar la lista de puntos(ruta)
  showAlert() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desea guardar el camino marcado?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                //Vacia la lista de puntos
                puntos.clear();
              });
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              //TODO: Guardar Ruta
              setState(() {
                //Vacia la lista de puntos
                puntos.clear();
              });
            },
            child: const Text('Si'),
          ),
        ],
      ),
    );
  }

  //Boton para ubicar posicion del movil
  floatingActionButton() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: FloatingActionButton(
        onPressed: () {
          moveCenter();
        },
        child: Icon(Icons.my_location),
      ),
    );
  }
}
