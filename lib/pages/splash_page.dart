import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:me_voy_usuario/blocs/location_permissions/location_permission_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:me_voy_usuario/blocs/bus/bus_bloc.dart';
import 'package:me_voy_usuario/blocs/stop/stop_bloc.dart';
import 'package:me_voy_usuario/services/socket_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    final stopsBloc = Provider.of<StopBloc>(context, listen: false);
    final busesBloc = Provider.of<BusBloc>(context, listen: false);
    final socket = Provider.of<SocketService>(context, listen: false).socket;

    socket.connect();
    socket.on("loadBuses", (data) => busesBloc.add(SaveBusesEvent(data)));
    socket.on("loadStops", (data) => stopsBloc.add(SaveStopsEvent(data)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusBloc, BusState>(
      builder: (context, bustate) {
        return BlocBuilder<StopBloc, StopState>(
          builder: (context, stopstate) {
            return BlocBuilder<LocationPermissionBloc, LocationPermissionState>(
              builder: (context, locationPermstate) {
                if (locationPermstate is! CheckingPermissionsState) {
                  if (locationPermstate
                      is! LocationPermissionIsGrantedAndLocationIsEnabledState) {
                    Future.delayed(Duration.zero, () {
                      Navigator.pushReplacementNamed(context, 'location-perm');
                      FlutterNativeSplash.remove();
                    });
                  } else if (bustate is BusesLoadedState &&
                      stopstate is StopsLoadedState) {
                    Future.delayed(Duration.zero, () {
                      Navigator.pushReplacementNamed(context, 'home');
                    });
                  }
                }
                return Container();
              },
            );
          },
        );
      },
    );
  }
}
