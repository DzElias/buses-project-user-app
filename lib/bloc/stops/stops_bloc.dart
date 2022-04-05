import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:medirutas/models/busStop.dart';
import 'package:medirutas/services/stops_service.dart';

part 'stops_event.dart';
part 'stops_state.dart';

class StopsBloc extends Bloc<StopsEvent, StopsState> {
  StopService stopService;
  StopsBloc({required this.stopService}) : super(StopsState()) {
    on<OnStopsFoundEvent>(
        (event, emit) => emit(state.copyWith(stops: event.stops)));
  }

  Future getStops() async {
    final stops = await stopService.getStops();
    add(OnStopsFoundEvent(stops));
  }

  addWait(dynamic payload) {
    String stopId = payload[0];
    var stops = state.stops;
    var i = stops.indexWhere((element) => element.id == stopId);
    stops[i].esperas = stops[i].esperas + 1;
    add(OnStopsFoundEvent(stops));
  }

  substractWait(dynamic payload){
    String stopId = payload[0];
    var stops = state.stops;
    var i = stops.indexWhere((element) => element.id == stopId);
    stops[i].esperas = stops[i].esperas - 1;
    add(OnStopsFoundEvent(stops));
  }
}
