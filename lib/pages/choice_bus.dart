import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:medirutas/bloc/my_location/my_location_bloc.dart';
import 'package:medirutas/bloc/stops/stops_bloc.dart';
import 'package:medirutas/models/bus.dart';
import 'package:medirutas/models/busStop.dart';

import 'package:medirutas/pages/home/models/home_page_arguments.dart';
import 'package:medirutas/widgets/custom_button.dart';
import 'package:medirutas/widgets/custom_input.dart';
import 'package:provider/provider.dart';

class ChoiceBus extends StatefulWidget {
  const ChoiceBus({Key? key}) : super(key: key);

  @override
  State<ChoiceBus> createState() => _ChoiceBusState();
}

class _ChoiceBusState extends State<ChoiceBus> {
  TextEditingController textController = TextEditingController();
  List<Bus> buses = [];
  List<Stop> stops = [];

  @override
  void initState() {
    final myLocationBloc = Provider.of<MyLocationBloc>(context, listen: false);
    myLocationBloc.startFollowing();
    final stopsBloc = Provider.of<StopsBloc>(context, listen: false);
    stopsBloc.getStops();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomInput(
                icon: Icons.directions_bus,
                placeHolder: 'ID del bus',
                textController: textController),
            CustomButton(
                btnColor: Colors.blueAccent,
                textColor: Colors.white,
                text: 'Buscar Bus',
                onPressed: () async {
                  String busID = '';
                  stops = await getStops();
                  await generateBusList();
                  textController.text.isNotEmpty
                      ? busID = findBusByID(buses, textController.text.trim())
                      : Fluttertoast.showToast(
                          msg: 'Indique un ID valido',
                          textColor: Colors.white,
                          backgroundColor: const Color(0xff606060));

                  busID.isNotEmpty
                      ? Navigator.pushReplacementNamed(context, 'home',
                          arguments: HomePageArguments(getBus(busID), stops))
                      : Fluttertoast.showToast(
                          msg: 'No existe el bus',
                          textColor: Colors.white,
                          backgroundColor: const Color(0xff606060));
                })
          ],
        ),
      ),
    );
  }

  generateBusList() async {
    final response =
        await get(Uri.parse('https://milab-cde.herokuapp.com/coordenadas/bus'));
    List<Bus> busesToAdd = [];
    List data = jsonDecode(response.body);
    for (var singleBus in data) {
      Bus bus = Bus.fromJson(singleBus);
      busesToAdd.add(bus);
    }
    setState(() {
      buses = busesToAdd;
    });
  }

  Bus getBus(String id) {
    int index = buses.indexWhere((element) => element.id == id);
    return buses[index];
  }

  Future<List<Stop>> getStops() async {
    final response = await get(
        Uri.parse('https://pruebas-socket.herokuapp.com/coordenadas'));
    List data = jsonDecode(response.body);
    List<Stop> busStops = [];

    for (var singleStop in data) {
      Stop stop = Stop.fromJson(singleStop);
      busStops.add(stop);
    }
    return busStops;
  }

  /// Find a person in the list using indexWhere method.
  String findBusByID(List<Bus> buses, String busID) {
    // Find the index of person. If not found, index = -1
    final index = buses.indexWhere((element) => element.id == busID);
    if (index >= 0) {
      return buses[index].id;
    } else {
      return '';
    }
  }
}
