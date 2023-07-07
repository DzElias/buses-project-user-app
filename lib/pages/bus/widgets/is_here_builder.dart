import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:me_voy_usuario/blocs/bus/bus_bloc.dart';
import 'package:me_voy_usuario/blocs/travel/travel_bloc.dart';
import 'package:me_voy_usuario/blocs/user_location/user_location_bloc.dart';
import 'package:me_voy_usuario/models/bus.dart';
import 'package:me_voy_usuario/models/stop.dart';
import 'package:me_voy_usuario/utils/matrix.dart';
import 'package:provider/provider.dart';

class IsHereBuilder extends StatefulWidget {
  const IsHereBuilder({
    Key? key,
    required this.busId,
    required this.stop,
  }) : super(key: key);

  final String busId;
  final Stop stop;

  @override
  State<IsHereBuilder> createState() => _IsHereBuilderState();
}

class _IsHereBuilderState extends State<IsHereBuilder> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserLocationBloc, UserLocationState>(
        builder: (context, userstate) {
      var userLstate = userstate as UserLocationLoaded;
      var userLocation = LatLng(userLstate.latitude, userLstate.longitude);
      return BlocBuilder<BusBloc, BusState>(
        builder: (context, busestate) {
          if (busestate is BusesLoadedState) {
            final Bus bus = busestate.buses
                .firstWhere((element) => element.id == widget.busId);
            LatLng busLocation = LatLng(bus.latitude, bus.longitude);
            LatLng stopLocation =
                LatLng(widget.stop.latitude, widget.stop.longitude);

            if (Matrix().calculateDistanceInMeters(userLocation, stopLocation) >
                    150 ||
                Matrix().calculateDistanceInMeters(busLocation, stopLocation) >
                    150) {
              Provider.of<TravelBloc>(context, listen: false)
                  .add(UnWaitEvent(context));
              Future.delayed(Duration.zero).then((value) {
                setState(() {});
              });
            }
          }
          return Container();
        },
      );
    });
  }
}
