import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:medirutas/models/bus.dart';
import 'package:medirutas/pages/home/models/home_page_arguments.dart';
import 'package:medirutas/widgets/custom_button.dart';
import 'package:medirutas/widgets/custom_input.dart';

class ChoiceBus extends StatefulWidget {
  const ChoiceBus({Key? key}) : super(key: key);

  @override
  State<ChoiceBus> createState() => _ChoiceBusState();
}

class _ChoiceBusState extends State<ChoiceBus> {
  TextEditingController textController = TextEditingController();
  List<Bus> buses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomInput(icon:  Icons.directions_bus, placeHolder: 'ID del bus', textController: textController),
          Custom_button(
            btnColor: Colors.blueAccent,
            textColor: Colors.white,
            text: 'Buscar Bus',
            onPressed: ()async{
              String busID = '';
              await generateBusList();
              textController.text.isNotEmpty ? busID=findBusByID(buses, textController.text) : Fluttertoast.showToast(msg: 'Indique un ID valido', textColor: Colors.white, backgroundColor: Color(0xff606060)) ;

              busID.isNotEmpty ? Navigator.pushReplacementNamed(context, 'home', arguments: HomePageArguments(busID)) : Fluttertoast.showToast(msg: 'No existe el bus', textColor: Colors.white, backgroundColor: Color(0xff606060));
              
            }
          )
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
    setState(() { buses = busesToAdd;});
  }
  /// Find a person in the list using indexWhere method.
String findBusByID(List<Bus> buses,String busID) {
  // Find the index of person. If not found, index = -1
  final index = buses.indexWhere((element) => element.id == busID);
  if (index >= 0) {
    return buses[index].id;
  }else{
    return '';
  }
}
}