import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:me_voy_usuario/blocs/bus/bus_bloc.dart';
import 'package:me_voy_usuario/blocs/user_location/user_location_bloc.dart';
import 'package:me_voy_usuario/models/bus.dart';
import 'package:me_voy_usuario/models/stop.dart';
import 'package:me_voy_usuario/pages/bus/bus_page.dart';
import 'package:me_voy_usuario/pages/bus/widgets/bus_stop_widget.dart';
import 'package:me_voy_usuario/pages/bus/widgets/panel_widget.dart';
import 'package:me_voy_usuario/utils/matrix.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class BusRoutePanel extends StatefulWidget {
  const BusRoutePanel(
      {Key? key, required this.panelController, required this.bus})
      : super(key: key);

  final PanelController panelController;
  final Bus bus;

  @override
  State<BusRoutePanel> createState() => _BusRoutePanelState();
}

class _BusRoutePanelState extends State<BusRoutePanel> {
  @override
  Widget build(BuildContext context) {
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.1;
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.53;

    return BlocBuilder<UserLocationBloc, UserLocationState>(
      builder: (context, userLocationstate) {
        if (userLocationstate is UserLocationLoaded) {
          return BlocBuilder<BusBloc, BusState>(
            builder: (context, busstate) {
              if (busstate is BusesLoadedState) {
                bool onnOrOff = false;
                var stops = widget.bus.stops.map((stopId) {
                  if (stopId == widget.bus.nextStop) {
                    onnOrOff = true;
                  }
                  Stop stop = Matrix().stopById(stopId, context);

                  List<int> time = Matrix()
                      .calculateTimeBus(widget.bus, stopId, context, true);
                  return StopWidget(
                      onn: onnOrOff, directionName: stop.title, time: time);
                }).toList();
                return SlidingUpPanel(
                    controller: widget.panelController,
                    maxHeight: panelHeightOpen,
                    parallaxEnabled: true,
                    parallaxOffset: .5,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                    onPanelSlide: (position) {
                      return setState(() {
                        final panelMaxScrollExtent =
                            panelHeightOpen - panelHeightClosed;
                        BusPage.of(context)?.setFabHeight =
                            position * panelMaxScrollExtent + 100;
                      });
                    },
                    panelBuilder: (controller) => PanelWidget(
                        controller: controller,
                        panelController: widget.panelController,
                        panelContent: Column(
                          children: [
                            Column(
                              children: [
                                Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: const Text('Ruta del Bus',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ))),
                                Column(
                                  children: stops,
                                )
                              ],
                            ),
                          ],
                        )));
              }
              return Container();
            },
          );
        }
        return Container();
      },
    );
  }
}
