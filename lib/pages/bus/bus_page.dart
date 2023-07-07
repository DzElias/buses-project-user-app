import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:me_voy_usuario/blocs/bus/bus_bloc.dart';
import 'package:me_voy_usuario/blocs/travel/travel_bloc.dart';
import 'package:me_voy_usuario/blocs/user_location/user_location_bloc.dart';
import 'package:me_voy_usuario/models/bus.dart';
import 'package:me_voy_usuario/models/stop.dart';
import 'package:me_voy_usuario/pages/bus/widgets/bus_route_panel.dart';
import 'package:me_voy_usuario/pages/bus/widgets/is_here_builder.dart';
import 'package:me_voy_usuario/pages/bus/widgets/travel_warning_panel.dart';
import 'package:me_voy_usuario/pages/bus/widgets/unwait_button.dart';
import 'package:me_voy_usuario/pages/bus/widgets/wait_button.dart';
import 'package:me_voy_usuario/pages/bus/widgets/waiting_builder.dart';
import 'package:me_voy_usuario/utils/matrix.dart';
import 'package:me_voy_usuario/widgets/custom_appBar.dart';
import 'package:me_voy_usuario/widgets/map_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:me_voy_usuario/widgets/custom_floating_button.dart';

class BusPage extends StatefulWidget {
  BusPage({Key? key, required this.bus, required this.stopSelected})
      : super(key: key);

  final Bus bus;
  final List<Stop> stopSelected;

  @override
  State<BusPage> createState() => BusPageState();
  static BusPageState? of(BuildContext context) =>
      context.findAncestorStateOfType<BusPageState>();
}

class BusPageState extends State<BusPage> with TickerProviderStateMixin {
  MapController mapController = MapController();
  static const double fabHeightClosed = 100.0;
  double fabHeight = fabHeightClosed;

  final panelController = PanelController();

  set setFabHeight(double value) => setState(() => fabHeight = value);

  @override
  Widget build(BuildContext context) {
    String titleT = (widget.bus.line != "99")
        ? 'Linea ${widget.bus.line} - ${widget.bus.company}'
        : '${widget.bus.company}';
    return BlocBuilder<TravelBloc, TravelState>(
        builder: (context, travelstate) {
      return WillPopScope(
        onWillPop: (travelstate is WaitingState)
            ? () async {
                return false;
              }
            : () async {
                return true;
              },
        child: Scaffold(
          floatingActionButton: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 60,
                right: 5,
                child: CustomFloatingButton(
                  tickerProvider: this,
                  mapController: mapController,
                  heroTag: 'centerUserLoc',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              BlocBuilder<BusBloc, BusState>(
                builder: (context, state) {
                  if (state is BusesLoadedState) {
                    if (state.buses
                        .where((element) => element.id == widget.bus.id)
                        .isEmpty) {
                      Future.delayed(Duration.zero).then((value) =>
                          Navigator.popUntil(
                              context, ModalRoute.withName('home')));
                    }
                    return Positioned(
                      top: 120,
                      right: 5,
                      child: CustomFloatingButton(
                          heroTag: 'centerBusLoc',
                          tickerProvider: this,
                          mapController: mapController,
                          bus: state.buses.firstWhere(
                              (element) => element.id == widget.bus.id)),
                    );
                  }
                  return Container();
                },
              )
            ],
          ),
          appBar: CustomAppBar(
            titleT,
            backgroundColor: Colors.white,
            elevation: 2,
            centerTitle: false,
            goBack: (travelstate is WaitingState) ? false : true,
          ),
          body: Stack(
            children: [
              MapWidget(
                  stopsSelected: widget.stopSelected,
                  bus: widget.bus,
                  mapController: mapController),
              BusRoutePanel(
                panelController: panelController,
                bus: widget.bus,
              ),
              (travelstate is NoTravelingState)
                  ? BlocBuilder<BusBloc, BusState>(
                      builder: (context, busState) {
                      Bus bus = (busState as BusesLoadedState)
                          .buses
                          .firstWhere((element) => element.id == widget.bus.id);
                      LatLng busLocation = LatLng(bus.latitude, bus.longitude);
                      return BlocBuilder<UserLocationBloc, UserLocationState>(
                          builder: (context, userLocationState) {
                        var usrState = userLocationState as UserLocationLoaded;
                        LatLng userLocation =
                            LatLng(usrState.latitude, usrState.longitude);

                        return (Matrix().calculateDistanceInMeters(
                                    userLocation, busLocation) >
                                50)
                            ? WaitButton(
                                parent: widget,
                                fabHeight: fabHeight,
                              )
                            : SizedBox();
                      });
                    })
                  : Container(),
              (travelstate is WaitingState)
                  ? (!travelstate.isHere)
                      ? Stack(
                          children: [
                            const TravelWarningPanel(
                              message: 'Espera al bus en la parada!',
                            ),
                            UnWaitButton(fabHeight: fabHeight),
                            WaitingBuilder(
                                busId: widget.bus.id,
                                stop: widget.stopSelected[0])
                          ],
                        )
                      : Stack(
                          children: [
                            const TravelWarningPanel(
                                message:
                                    'El bus esta llegando, identificalo y subite!'),
                            IsHereBuilder(
                              busId: widget.bus.id,
                              stop: widget.stopSelected[0],
                            )
                          ],
                        ) // Esta esperando, ya llego

                  : Container(),
            ],
          ),
        ),
      );
    });
  }
}
