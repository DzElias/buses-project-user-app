import 'package:flutter/material.dart';
import 'package:me_voy_usuario/models/bus.dart';
import 'package:me_voy_usuario/models/stop.dart';
import 'package:me_voy_usuario/pages/bus/bus_page.dart';

class BusWidget extends StatelessWidget {
  final Bus bus;
  final String time;
  final Stop stop;

  const BusWidget(
      {Key? key, required this.bus, required this.time, required this.stop})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => BusPage(
                        bus: bus,
                        stopSelected: [stop],
                      )));
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_bus,
                      color: Colors.green,
                      size: 30,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    (bus.line != '99')
                        ? Text("Linea ${bus.line} ${bus.company}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16))
                        : Text("${bus.company}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16))
                  ],
                ),
                Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(Icons.keyboard_arrow_right,
                        color: Colors.black87)
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
