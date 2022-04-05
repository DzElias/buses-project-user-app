import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:medirutas/bloc/my_location/my_location_bloc.dart';
import 'package:medirutas/bloc/stops/stops_bloc.dart';
import 'package:medirutas/helpers/cached_tile_provider.dart';
import 'package:medirutas/models/bus.dart';
import 'package:medirutas/models/busStop.dart';
import 'package:medirutas/models/walking_route.dart';
import 'package:medirutas/pages/home/models/home_page_arguments.dart';
import 'package:medirutas/services/socket_service.dart';
import 'package:medirutas/widgets/main_drawer.dart';
import 'package:provider/provider.dart';

const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiZWxpYXNkaWF6MTAwNSIsImEiOiJja3d4eDQ3OTcwaHk3Mm51cjNmcWRvZjA2In0.AAF794oxyxFR_-wAvVwMfQ';
const MAPBOX_STYLE = 'mapbox/light-v10';

class MapActivity extends StatefulWidget {
  const MapActivity({Key? key}) : super(key: key);

  @override
  _MapActivityState createState() => _MapActivityState();
}

class _MapActivityState extends State<MapActivity>
    with TickerProviderStateMixin {
  List<LatLng> rutaCoords = [];
  late Bus buss;
  List<Stop> stopss = [];
  @override
  void initState() {
    super.initState();
    final stopsBloc = Provider.of<StopsBloc>(context, listen: false);
    final SocketService socketService =
        Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('addWaitReturn', stopsBloc.addWait);
    socketService.socket.on('substractWaitReturn', stopsBloc.substractWait);

    //mueve el centro a la ultima ubicacion obtenida
    moveCenter();
  }
  // printData(dynamic payload){
  //   print('<<<<<<<<___---------->>>>>>>>>>>>>>>>');
  //   print(payload);

  // }
  late Position currentLocation;
  final MapController mapController = MapController();

  bool startStop = true;

  @override
  Widget build(BuildContext context) {
    Polyline _rutaParada =
        Polyline(points: rutaCoords, strokeWidth: 2, color: Colors.green);

    var width = MediaQuery.of(context).size.width;
    final socketService = Provider.of<SocketService>(context, listen: false);

    final args =
        ModalRoute.of(context)!.settings.arguments as HomePageArguments;
    final Bus bus = args.bus;
    buss = bus;
    final List<Stop> stops = args.stops;
    stopss = stops;
    final points = polylinePoints.decodePolyline(buss.ruta);

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        floatingActionButton: floatingActionButton(),
        drawer: const MainDrawer(),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.black)),
        body: Stack(
          children: [
            BlocBuilder<MyLocationBloc, MyLocationState>(
              builder: (context, state) {
                return FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                      onMapCreated: createMarkers(),
                      center: state.location,
                      zoom: 17,
                      minZoom: 13,
                      maxZoom: 18,
                      interactiveFlags:
                          InteractiveFlag.all & ~InteractiveFlag.rotate),
                  layers: [
                    TileLayerOptions(
                        urlTemplate:
                            "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
                        additionalOptions: {
                          'accessToken': MAPBOX_ACCESS_TOKEN,
                          'id': MAPBOX_STYLE
                        },
                        tileProvider: const CachedTileProvider()),
                    !startStop
                        ? PolylineLayerOptions(polylines: [
                            Polyline(
                                strokeWidth: 3.0,
                                color: Colors.blueAccent,
                                points: points
                                    .map((point) => LatLng(point.latitude / 10,
                                        point.longitude / 10))
                                    .toList())
                          ])
                        : PolylineLayerOptions(),
                    PolylineLayerOptions(polylines: [_rutaParada]),
                    MarkerLayerOptions(markers: [
                      Marker(
                          point: state.location!,
                          width: 60,
                          height: 60,
                          builder: (_) => const Center(
                                child:
                                    Image(image: AssetImage("assets/bus.png")),
                              ))
                    ]),
                    MarkerLayerOptions(
                        markers: stopss
                            .map((stop) => Marker(
                                width: 60,
                                height: 60,
                                point: LatLng(stop.latitud, stop.longitud),
                                builder: (_) => const Center(
                                      child: Image(
                                          image: AssetImage("assets/stop.png")),
                                    )))
                            .toList()),
                  ],
                );
              },
            ),
            startStopButton(bus.id, socketService),
            !startStop ? showTablero(width, bus) : const SizedBox(),
            !startStop
                ? startTracking(bus.id, socketService)
                : const SizedBox(),
          ],
        ));
  }

  Positioned showTablero(double width, Bus bus) {
    return Positioned(
      child: Container(
        height: 150,
        width: width,
        decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Linea ${bus.linea} ${bus.titulo}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Ve a:  ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                  Text(getStopById(bus.proximaParada).titulo,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  const Text(
                    "Esperando:  ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                  BlocBuilder<StopsBloc, StopsState>(
                    builder: (context, state) {
                      String proxStopID = getStopById(bus.proximaParada).id;
                      Stop proxStop = state.stops[state.stops.indexWhere((element) => element.id == proxStopID)];

                      return Text(
                          proxStop.esperas.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600));
                    },
                  ),
                ],
              )
            ],
          ),
        ]),
      ),
      top: 80,
      right: 80,
      left: 20,
    );
  }

  final baseUrl = 'https://api.mapbox.com/directions/v5';
  final _dio = new Dio();
  PolylinePoints polylinePoints = PolylinePoints();
  Future crear_ruta_a_parada(LatLng inicio, LatLng destino) async {
    final url =
        '${baseUrl}/mapbox/driving/${inicio.longitude},${inicio.latitude};${destino.longitude},${destino.latitude}';

    final resp = await this._dio.get(url, queryParameters: {
      'alternatives': 'false',
      'geometries': 'polyline6',
      'steps': 'false',
      'access_token': MAPBOX_ACCESS_TOKEN,
      'language': 'es',
    });

    final data = WalkingRoute.fromJson(resp.data);
    final geometry = data.routes[0].geometry;
    final points = polylinePoints.decodePolyline(geometry);

    setState(() {
      rutaCoords = points
          .map((point) => LatLng(point.latitude / 10, point.longitude / 10))
          .toList();
    });
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
                primary: startStop ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    startStop
                        ? const Icon(
                            Icons.navigation,
                            size: 30,
                          )
                        : const Icon(
                            Icons.close,
                            size: 30,
                          ),
                    const SizedBox(width: 5),
                    startStop
                        ? const Text(
                            'Iniciar recorrido',
                            style: TextStyle(fontSize: 20),
                          )
                        : const Text(
                            'Finalizar recorrido',
                            style: TextStyle(fontSize: 20),
                          )
                  ],
                ),
              ),
              onPressed: () {
                if (startStop) {
                  final myLocation =
                      Provider.of<MyLocationBloc>(context, listen: false)
                          .state
                          .location;
                  crear_ruta_a_parada(
                      myLocation!,
                      LatLng(
                        getStopById(buss.proximaParada).latitud,
                        getStopById(buss.proximaParada).longitud,
                      ));
                }
                if (!startStop) {
                  setState(() {
                    rutaCoords = [];
                  });
                }
                startOrStop(busID, socketService);
              }),
        ));
  }

  Stop getStopById(String id) {
    int index = stopss.indexWhere((element) => element.id == id);
    return stopss[index];
  }

  //Funcion que verifica si esta trackeando o no
  startOrStop(String busID, SocketService socketService) {
    if (startStop) {
      setState(() {
      startStop = false;
    });
    } else {
      stopTracking();
    }
  }

  //Empezar tracking
  Widget startTracking(String busID, SocketService socketService) {
    
    return BlocBuilder<MyLocationBloc, MyLocationState>(
      builder: (context, state) {
        var position = state.location;
        List changeLocationReq = [
          busID,
          '${position?.latitude}',
          '${position?.longitude}'
        ];
        animatedMapMove(position!, mapController.zoom);

        socketService.socket.emit('change-location', [changeLocationReq]);
        

        return Container();
      },
    );

    // });
  }

  //finalizar ruta y detener el stream
  stopTracking() {
    setState(() {
      startStop = true;
    });
  }

  //Obtener ultima ubicacion del movil y ubicar en el centro
  moveCenter() async {
    Position? position = await Geolocator.getLastKnownPosition();
    animatedMapMove((LatLng(position!.latitude, position.longitude)), 17);
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
                // puntos.clear();
              });
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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
      margin: const EdgeInsets.only(top: 40),
      child: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 3,
        onPressed: () {
          moveCenter();
        },
        child: const Icon(
          Icons.my_location,
          color: Colors.green,
        ),
      ),
    );
  }

  createMarkers() {}
}
