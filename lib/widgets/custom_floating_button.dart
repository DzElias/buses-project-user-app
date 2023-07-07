import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:me_voy_usuario/blocs/map/map_bloc.dart';
import 'package:me_voy_usuario/blocs/user_location/user_location_bloc.dart';
import 'package:me_voy_usuario/models/bus.dart';
import 'package:provider/provider.dart';

class CustomFloatingButton extends StatelessWidget {
  const CustomFloatingButton(
      {Key? key,
      required this.tickerProvider,
      required this.mapController,
      this.bus,
      required this.heroTag})
      : super(key: key);

  final TickerProvider tickerProvider;
  final MapController mapController;
  final Bus? bus;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      child: FloatingActionButton(
          heroTag: heroTag,
          elevation: 5,
          mini: true,
          backgroundColor: Colors.white,
          child: (bus == null)
              ? const Icon(Icons.my_location, color: Colors.blueAccent)
              : Icon(
                  Icons.directions_bus,
                  color: Colors.blueAccent,
                ),
          onPressed: () {
            final userLocationBlocState =
                Provider.of<UserLocationBloc>(context, listen: false).state;
            if (userLocationBlocState is UserLocationLoaded) {
              var mapBloc = Provider.of<MapBloc>(context, listen: false);
              var mapBlocState = mapBloc.state;
              if (mapBlocState is MapLoadedState) {
                (bus == null)
                    ? mapBloc.animatedMapMove(
                        LatLng(userLocationBlocState.latitude,
                            userLocationBlocState.longitude),
                        16,
                        tickerProvider,
                        mapController)
                    : mapBloc.animatedMapMove(
                        LatLng(bus!.latitude, bus!.longitude),
                        16,
                        tickerProvider,
                        mapController);
              }
            }
          }),
    );
  }
}
