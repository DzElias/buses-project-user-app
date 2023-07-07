import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:me_voy_usuario/blocs/bus/bus_bloc.dart';
import 'package:me_voy_usuario/blocs/internet_connection/internet_connection_bloc.dart';
import 'package:me_voy_usuario/blocs/location_permissions/location_permission_bloc.dart';
import 'package:me_voy_usuario/blocs/map/map_bloc.dart';
import 'package:me_voy_usuario/blocs/stop/stop_bloc.dart';
import 'package:me_voy_usuario/blocs/user_location/user_location_bloc.dart';
import 'package:me_voy_usuario/pages/home/widgets/stop_page_view.dart';
import 'package:me_voy_usuario/widgets/custom_appBar.dart';
import 'package:me_voy_usuario/widgets/custom_floating_button.dart';
import 'package:me_voy_usuario/widgets/map_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  MapController mapController = MapController();

  @override
  void initState() {
    Provider.of<InternetConnectionBloc>(context, listen: false)
        .add(StartListenInternetConnection());

    Provider.of<UserLocationBloc>(context, listen: false)
        .add(StartFollowingEvent());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar("Paradas de Buses",
          goBack: true,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: CustomFloatingButton(
        tickerProvider: this,
        mapController: mapController,
        heroTag: 'centerUserLoc',
      ),
      body: BlocBuilder<LocationPermissionBloc, LocationPermissionState>(
        builder: (context, locationPermstate) {
          if (locationPermstate
              is! LocationPermissionIsGrantedAndLocationIsEnabledState) {
            Future.delayed(Duration.zero, () {
              Navigator.pushReplacementNamed(context, 'location-perm');
            });
          }
          return BlocBuilder<UserLocationBloc, UserLocationState>(
            builder: (context, userLocationstate) {
              return BlocBuilder<MapBloc, MapState>(
                builder: (context, mapstate) {
                  return BlocBuilder<StopBloc, StopState>(
                    builder: (context, stopstate) {
                      return BlocBuilder<BusBloc, BusState>(
                        builder: (context, busstate) {
                          if (userLocationstate is UserLocationLoaded &&
                              stopstate is StopsLoadedState &&
                              busstate is BusesLoadedState) {
                            Future.delayed(Duration.zero)
                                .then((value) => FlutterNativeSplash.remove());
                            return Scaffold(
                              body: Stack(
                                children: [
                                  MapWidget(
                                    mapController: mapController,
                                    stopsSelected: [],
                                  ),
                                  const StopsPageView()
                                ],
                              ),
                            );
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.deepPurpleAccent.shade400,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
