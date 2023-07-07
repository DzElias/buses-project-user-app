import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:me_voy_usuario/blocs/bus/bus_bloc.dart';
import 'package:me_voy_usuario/blocs/map/map_bloc.dart';
import 'package:me_voy_usuario/models/bus.dart';
import 'package:me_voy_usuario/models/stop.dart';
import 'package:me_voy_usuario/pages/stop/widgets/buses_approaching_box.dart';
import 'package:me_voy_usuario/utils/matrix.dart';
import 'package:me_voy_usuario/widgets/custom_appBar.dart';
import 'package:me_voy_usuario/widgets/custom_floating_button.dart';
import 'package:me_voy_usuario/widgets/map_widget.dart';
import 'package:provider/provider.dart';

class StopPage extends StatefulWidget {
  const StopPage({Key? key, required this.stop}) : super(key: key);

  final Stop stop;

  @override
  State<StopPage> createState() => _StopPageState();
}

class _StopPageState extends State<StopPage> with TickerProviderStateMixin {
  MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero).then((_) =>
        Provider.of<MapBloc>(context, listen: false).animatedMapMove(
            LatLng(widget.stop.latitude, widget.stop.longitude),
            16,
            this,
            mapController));
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: CustomFloatingButton(
        tickerProvider: this,
        mapController: mapController,
        heroTag: 'centerUserL',
      ),
      appBar: CustomAppBar(
        widget.stop.title,
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 2,
        goBack: true,
      ),
      body: Stack(
        children: [
          MapWidget(
            mapController: mapController,
            stopsSelected: [widget.stop],
          ),
          BlocBuilder<BusBloc, BusState>(
            builder: (context, state) {
              return BusesApproachingBox(
                  stop: widget.stop, buses: generateBusList(widget.stop.id));
            },
          )
        ],
      ),
    );
  }

  List<Bus> generateBusList(String stopId) {
    List<Bus> buses = [];
    final busBloc = Provider.of<BusBloc>(context, listen: false);
    var busBlocState = busBloc.state;
    if (busBlocState is BusesLoadedState) {
      List<Bus> busesToAdd = busBlocState.buses;

      for (var singleBus in busesToAdd) {
        if (singleBus.stops.indexWhere((element) => element == stopId) >= 0) {
          buses.add(singleBus);
        }
      }

      buses.sort((a, b) {
        int aTime = Matrix().calculateTimeBus(a, stopId, context, false);
        int bTime = Matrix().calculateTimeBus(b, stopId, context, false);

        return (aTime).compareTo(bTime);
      });
      return buses;
    }
    return [];
  }
}
