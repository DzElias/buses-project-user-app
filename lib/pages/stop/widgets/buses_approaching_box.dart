import 'package:flutter/material.dart';
import 'package:me_voy_usuario/models/bus.dart';
import 'package:me_voy_usuario/models/stop.dart';
import 'package:me_voy_usuario/pages/stop/widgets/bus_widget.dart';
import 'package:me_voy_usuario/utils/matrix.dart';

class BusesApproachingBox extends StatefulWidget {
  const BusesApproachingBox({
    Key? key,
    required this.stop,
    required this.buses,
  }) : super(key: key);
  final Stop stop;
  final List<Bus> buses;

  @override
  State<BusesApproachingBox> createState() => _BusesApproachingBoxState();
}

class _BusesApproachingBoxState extends State<BusesApproachingBox> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 5,
        left: 5,
        right: 5,
        height: MediaQuery.of(context).size.height * 0.35,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: Colors.green,
                    //
                  ),
                  child: Center(
                      child: Text('Buses en camino'.toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15))),
                ),
                Container(
                    height: (MediaQuery.of(context).size.height * 0.35) - 60,
                    child: widget.buses.isNotEmpty
                        ? ListView.builder(
                            itemCount: widget.buses.length,
                            itemBuilder: (_, i) {
                              return BusWidget(
                                  bus: widget.buses[i],
                                  time: Matrix().calculateTimeBusString(
                                      widget.buses[i], widget.stop.id, context),
                                  stop: widget.stop);
                            })
                        : Center(
                            child: Text(
                                "No encontramos ningun Bus acercandose :("),
                          ))
              ],
            ),
          ),
        ));
  }
}
