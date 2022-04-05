import 'package:medirutas/models/bus.dart';
import 'package:medirutas/models/busStop.dart';

class HomePageArguments {
  final Bus bus;
  List<Stop> stops = [];

  HomePageArguments(this.bus, this.stops);
}
