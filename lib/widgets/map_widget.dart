import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:me_voy_usuario/blocs/bus/bus_bloc.dart';
import 'package:me_voy_usuario/blocs/map/map_bloc.dart';
import 'package:me_voy_usuario/blocs/stop/stop_bloc.dart';
import 'package:me_voy_usuario/blocs/stops_page_view/stops_page_view_bloc.dart';
import 'package:me_voy_usuario/blocs/travel/travel_bloc.dart';
import 'package:me_voy_usuario/blocs/user_location/user_location_bloc.dart';
import 'package:me_voy_usuario/models/bus.dart';
import 'package:me_voy_usuario/models/stop.dart';
import 'package:me_voy_usuario/utils/cachedTileProvider.dart';
import 'package:me_voy_usuario/utils/map_utils.dart';
import 'package:me_voy_usuario/utils/matrix.dart';
import 'package:me_voy_usuario/widgets/stop_marker.dart';
import 'package:me_voy_usuario/widgets/user_location_marker.dart';
import 'package:polyline_codec/polyline_codec.dart';
import 'package:provider/provider.dart';

const mapboxAccessToken =
    'pk.eyJ1IjoiZWxpYXNkaWF6MTAwNSIsImEiOiJjbDUxdGpveGUwOHhzM2pwajZjNWVjaHYwIn0.aFD-rLHhe8R-vYYh3OYHKw';

class MapWidget extends StatefulWidget {
  MapWidget(
      {Key? key,
      this.bus,
      required this.mapController,
      required this.stopsSelected})
      : super(key: key);

  final MapController mapController;
  final List<Stop> stopsSelected;
  final Bus? bus;
  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  List<LatLng> firstRoute = [];
  List<LatLng> scndRoute = [];
  late AnimationController animationController;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    animationController.repeat(reverse: true);
    createWalkingsRoutes(widget.stopsSelected);
    super.initState();
  }

  Bus? busToTrack;
  @override
  Widget build(BuildContext context) {
    Polyline firstStopRoute = Polyline(
        points: firstRoute, strokeWidth: 6, color: Colors.blue, isDotted: true);
    Polyline destinationRoute = Polyline(
        points: scndRoute, strokeWidth: 6, color: Colors.blue, isDotted: true);

    var busRoute = widget.bus?.ruta;
    Polyline? busRoutePolyline = (busRoute != null)
        ? Polyline(
            strokeWidth: 6,
            color: Colors.deepPurpleAccent.shade400,
            points: PolylineCodec.decode(busRoute)
                .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
                .toList())
        : null;
    return BlocBuilder<UserLocationBloc, UserLocationState>(
      builder: (context, userLocationstate) {
        if (userLocationstate is UserLocationLoaded) {
          LatLng userLocation =
              LatLng(userLocationstate.latitude, userLocationstate.longitude);

          return BlocBuilder<BusBloc, BusState>(
            builder: (context, bustate) {
              var busesBlocState = bustate;
              if (widget.bus != null && busesBlocState is BusesLoadedState) {
                Future.delayed(Duration.zero).then((value) {
                  setState(() {
                    busToTrack = busesBlocState.buses
                        .firstWhere((element) => element.id == widget.bus!.id);
                  });
                });
              }

              return BlocBuilder<TravelBloc, TravelState>(
                  builder: (context, travelstate) {
                if (travelstate is WaitingState) {
                  Future.delayed(Duration.zero).then((value) {
                    setState(() {
                      firstRoute = [];
                    });
                  });
                }
                return FlutterMap(
                  mapController: widget.mapController,
                  options: MapOptions(
                      center: userLocation,
                      minZoom: 6,
                      zoom: 16,
                      maxZoom: 18,
                      interactiveFlags:
                          InteractiveFlag.all & ~InteractiveFlag.rotate,
                      onMapCreated: (_) {
                        Future.delayed(Duration.zero).then((value) =>
                            Provider.of<MapBloc>(context, listen: false).add(
                                MapLoadedEvent(
                                    widget.mapController, userLocation)));
                      }),
                  layers: [
                    TileLayerOptions(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/eliasdiaz1005/cl51kvpz3001914laj756j70g/tiles/256/{z}/{x}/{y}@2x?access_token={access_token}',
                        additionalOptions: {"access_token": mapboxAccessToken},
                        tileProvider: const CachedTileProvider()),
                    (busRoutePolyline != null)
                        ? PolylineLayerOptions(polylines: [busRoutePolyline])
                        : PolylineLayerOptions(),
                    PolylineLayerOptions(
                        polylines: [firstStopRoute, destinationRoute]),
                    (busToTrack == null)
                        ? MarkerLayerOptions(markers: [
                            Marker(
                              height: 60,
                              width: 60,
                              point: userLocation,
                              builder: (_) =>
                                  UserLocationMarker(animationController),
                            )
                          ])
                        : ((Matrix().calculateDistanceInMeters(
                                    LatLng(busToTrack!.latitude,
                                        busToTrack!.longitude),
                                    userLocation) <
                                50))
                            ? MarkerLayerOptions(markers: [])
                            : MarkerLayerOptions(markers: [
                                Marker(
                                  height: 60,
                                  width: 60,
                                  point: userLocation,
                                  builder: (_) =>
                                      UserLocationMarker(animationController),
                                )
                              ]),
                    MarkerLayerOptions(
                        markers: createStopMarkers(userLocation)),
                    (busToTrack != null)
                        ? MarkerLayerOptions(markers: [
                            Marker(
                                height: 60,
                                width: 60,
                                point: LatLng(busToTrack!.latitude,
                                    busToTrack!.longitude),
                                builder: (_) => const Image(
                                      image: AssetImage(
                                          'assets/images/bus_point.png'),
                                      height: 60,
                                    ))
                          ])
                        : MarkerLayerOptions(),
                  ],
                );
              });
            },
          );
        }
        return Container();
      },
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    widget.mapController.dispose();
    super.dispose();
  }

  int _stopSelectedIndex = 0;
  List<Marker> createStopMarkers(LatLng userLocation) {
    final mapBloc = Provider.of<MapBloc>(context, listen: false);
    final mapBlocState = mapBloc.state;

    final stopBlocState = Provider.of<StopBloc>(context, listen: false).state;
    final pageController =
        Provider.of<StopsPageViewBloc>(context, listen: false).pageController;

    if (stopBlocState is StopsLoadedState) {
      List<Stop> stops = stopBlocState.stops;

      stops.sort(((a, b) {
        LatLng aLatLng = LatLng(a.latitude, a.longitude);
        LatLng bLatLng = LatLng(b.latitude, b.longitude);

        return Matrix()
            .calculateDistanceInMeters(aLatLng, userLocation)
            .compareTo(
                Matrix().calculateDistanceInMeters(bLatLng, userLocation));
      }));

      List<Marker> markers = stops
          .map((stop) => Marker(
              height: 60,
              width: 60,
              point: LatLng(stop.latitude, stop.longitude),
              builder: (_) {
                int i = stops.indexWhere((element) => element.id == stop.id);
                return GestureDetector(
                    onTap: () async {
                      if (widget.stopsSelected.isEmpty) {
                        _stopSelectedIndex = i;
                        if (mapBlocState is MapLoadedState) {
                          mapBloc.animatedMapMove(
                              LatLng(stop.latitude, stop.longitude),
                              widget.mapController.zoom,
                              this,
                              widget.mapController);

                          pageController.animateToPage(i,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut);
                        }
                      }
                    },
                    child: (widget.stopsSelected.isEmpty)
                        ? StopMarker(selected: i == _stopSelectedIndex)
                        : StopMarker(
                            selected: (widget.stopsSelected[0].id == stop.id)));
              }))
          .toList();
      return markers;
    }
    return [];
  }

  void createWalkingsRoutes(List<Stop> stopsSelected) async {
    if (stopsSelected.isNotEmpty) {
      final userLocationBlocState =
          Provider.of<UserLocationBloc>(context, listen: false).state;
      final mapBloc = Provider.of<MapBloc>(context, listen: false);
      var mapBlocState = mapBloc.state;
      if (userLocationBlocState is UserLocationLoaded) {
        LatLng userLocation = LatLng(
            userLocationBlocState.latitude, userLocationBlocState.longitude);
        List<List<LatLng>> walkingRoutes = await MapUtils()
            .createWalkingRoute(userLocation, stopsSelected, null);
        if (walkingRoutes.length == 1) {
          Future.delayed(Duration.zero).then((value) => setState(() {
                firstRoute = walkingRoutes[0];
              }));
          if (mapBlocState is MapLoadedState) {
            await Future.delayed(Duration.zero);

            mapBloc.animatedMapMove(firstRoute.last, widget.mapController.zoom,
                this, widget.mapController);
          }
          // } else if (walkingRoutes.length == 2) {
          //   setState(() {
          //     firstRoute = walkingRoutes[0];
          //     scndRoute = walkingRoutes[1];

          //     if (mapBlocState is MapLoadedState) {
          //       mapBloc.animatedMapMove(firstRoute.last,
          //           widget.mapController.zoom, this, widget.mapController);
          //     }
          // });
        }
      }
    }
  }
}
