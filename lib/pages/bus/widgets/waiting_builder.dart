import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:me_voy_usuario/blocs/bus/bus_bloc.dart';
import 'package:me_voy_usuario/blocs/travel/travel_bloc.dart';
import 'package:me_voy_usuario/blocs/user_location/user_location_bloc.dart';

import 'package:me_voy_usuario/models/bus.dart';
import 'package:me_voy_usuario/models/stop.dart';

import 'package:me_voy_usuario/services/socket_service.dart';

import 'package:me_voy_usuario/utils/matrix.dart';


class WaitingBuilder extends StatefulWidget {
  const WaitingBuilder({
    Key? key,
    required this.busId,
    required this.stop,
  }) : super(key: key);

  final String busId;
  final Stop stop;

  @override
  State<WaitingBuilder> createState() => _WaitingBuilderState();
}

class _WaitingBuilderState extends State<WaitingBuilder> with WidgetsBindingObserver {
  
  late AppLifecycleState notification;
  
  void backgroundJobForNotification;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

// ...

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      notification = state;
    });

    if (notification != AppLifecycleState.resumed) {

      Provider.of<SocketService>(context, listen: false).socket.connect();
      
      backgroundJobForNotification = Provider.of<SocketService>(context, listen: false).socket.on('loadBuses', (data) async {
        List<Bus> buses = [];
        
        for (var map in data) {
          Bus bus = Bus.fromMap(map);
          if (bus.isActive) {
            buses.add(bus);
          }
        }
        

        final Bus bus = buses.firstWhere((element) => element.id == widget.busId);
        
        LatLng busLocation = LatLng(bus.latitude, bus.longitude);
        
        LatLng stopLocation = LatLng(widget.stop.latitude, widget.stop.longitude);

        if (Matrix().calculateDistanceInMeters(busLocation, stopLocation) < 100) {
          //Lanzar notificacion
          print("El bus llego, puedo lanzar la notificacion");
        }
      });
    } else{
      backgroundJobForNotification = null;
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserLocationBloc, UserLocationState>(
        builder: (context, userLstate) {
      var userstate = userLstate as UserLocationLoaded;
      var userL = LatLng(userstate.latitude, userstate.longitude);
      return BlocBuilder<BusBloc, BusState>(
        builder: (context, busestate) {
          if (busestate is BusesLoadedState) {
            final Bus bus = busestate.buses
                .firstWhere((element) => element.id == widget.busId);
            LatLng busLocation = LatLng(bus.latitude, bus.longitude);
            LatLng stopLocation =
                LatLng(widget.stop.latitude, widget.stop.longitude);

            if (Matrix().calculateDistanceInMeters(busLocation, stopLocation) <
                100) {
              Provider.of<TravelBloc>(context, listen: false)
                  .add(IsHereEvent());
            }
            if (Matrix().calculateDistanceInMeters(userL, stopLocation) > 155) {
              Provider.of<TravelBloc>(context, listen: false)
                  .add(UnWaitEvent(context));
            }
          }
          return Container();
        },
      );
    });
  }
}
