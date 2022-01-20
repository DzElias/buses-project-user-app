import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:medirutas/helpers/cached_tile_provider.dart';
import 'package:medirutas/pages/home/models/home_page_arguments.dart';
import 'package:medirutas/services/socket_service.dart';
import 'package:provider/provider.dart';

class MapActivity extends StatefulWidget {
  const MapActivity({Key? key}) : super(key: key);

  @override
  _MapActivityState createState() => _MapActivityState();
}

class _MapActivityState extends State<MapActivity>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    
    // final SocketService socketService = Provider.of<SocketService>(context, listen: false);
    // socketService.socket.on('change-locationReturn', printData);
    //mueve el centro a la ultima ubicacion obtenida
    moveCenter();
  }
  // printData(dynamic payload){
  //   print('<<<<<<<<___---------->>>>>>>>>>>>>>>>');
  //   print(payload);

  // }
  late Position currentLocation;
  late StreamSubscription<Position> positionStream;
  final MapController mapController = MapController();

  //Lista de puntos
  List<LatLng> puntos = [];

  bool startStop = true;

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    final args =
        ModalRoute.of(context)!.settings.arguments as HomePageArguments;
    final String busId = args.busId;
    //mapa de markers
    var markers = puntos.map((latlng) {
      return Marker(
          height: 60,
          width: 60,
          point: latlng,
          builder: (_) => Container(
                  child: const Center(
                      child: Image(
                image: AssetImage('assets/bus.png'),
                height: 60,
                width: 60,
              ))));
    }).toList();

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        floatingActionButton: floatingActionButton(),
        body: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                  center: LatLng(0, -0), zoom: 16, minZoom: 16, maxZoom: 18),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                    tileProvider: const CachedTileProvider()),
                MarkerLayerOptions(markers: markers),
              ],
            ),
            startStopButton(busId, socketService),
          ],
        ));
  }

  animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  //Boton para empezar/terminar el trazado
  startStopButton(String busID, SocketService socketService) {
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
                            'Empezar ruta',
                            style: TextStyle(fontSize: 20),
                          )
                        : const Text(
                            'Finalizar ruta',
                            style: TextStyle(fontSize: 20),
                          )
                  ],
                ),
              ),
              onPressed: () {
                startOrStop(busID, socketService);
              }),
        ));
  }

  //Funcion que verifica si esta trackeando o no
  startOrStop(String busID, SocketService socketService) {
    if (startStop) {
      startTracking(busID, socketService);
    } else {
      stopTracking();
    }
  }

  //Empezar tracking
  startTracking(String busID, SocketService socketService) {
    setState(() {
      startStop = false;

      positionStream = Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.bestForNavigation,
                  distanceFilter: 10))
          .listen((Position position) {
        animatedMapMove(LatLng(position.latitude, position.longitude), mapController.zoom);
        print(busID);
        List busLocation = [
          busID,
          '${position.latitude}',
          '${position.longitude}'
        ];
        print(busLocation);
        //cosas de socket

        socketService.socket.emit('change-location', [busLocation]);

        //modificar constantemente el centro del mapa
        //mover el marcador a la posicion actual
        setState(() {
          puntos.clear();
          puntos.add(LatLng(position.latitude, position.longitude));
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
      puntos.clear();
      //Mostrar dialogo
      // showAlert();
    });
  }

  //Obtener ultima ubicacion del movil y ubicar en el centro
  moveCenter() async {
    Position? position = await Geolocator.getLastKnownPosition();
    animatedMapMove((LatLng(position!.latitude, position.longitude)), 16);
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
