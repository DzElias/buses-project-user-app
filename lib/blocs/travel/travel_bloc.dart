import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:me_voy_usuario/models/bus.dart';
import 'package:me_voy_usuario/models/stop.dart';
import 'package:me_voy_usuario/services/socket_service.dart';
import 'package:provider/provider.dart';

part 'travel_event.dart';
part 'travel_state.dart';

class TravelBloc extends Bloc<TravelEvent, TravelState> {
  TravelBloc() : super(NoTravelingState()) {
    on<IsHereEvent>((event, emit) {
      var travelState = state;
      if (travelState is WaitingState) {
        emit(NoTravelingState());
        emit(WaitingState(
            bus: travelState.bus,
            stopsSelected: travelState.stopsSelected,
            destino: travelState.destino,
            isHere: true));
      }
    });

    // on<IsTravelingEvent>((event, emit) {
    //   var travelState = state;
    //   if(travelState is WaitingState){
    //     emit(IsTravelingState(
    //     bus: travelState.bus,
    //     stopsSelected: travelState.stopsSelected,
    //     destino: travelState.destino
    //   ));
    //   unWait(event.context, travelState.stopsSelected[0].id);
    //   }

    // });

    // on<EndTravelEvent>((event, emit) {
    //   emit(NoTravelingState());
    // });

    on<WaitEvent>((event, emit) {
      //
      emit(WaitingState(
          bus: event.bus,
          stopsSelected: event.stopsSelected,
          isHere: false,
          destino: event.destino));

      wait(event.context, event.stopsSelected[0].id);
    });

    on<UnWaitEvent>((event, emit) {
      var travelState = state; //
      emit(NoTravelingState());
      if (travelState is WaitingState) {
        unWait(event.context, travelState.stopsSelected[0].id);
      }
    });

    // on<WalkToYourDestinationEvent>((event, emit){
    //   var travelState = state;
    //   if(travelState is IsTravelingState){
    //     emit(travelState.walkToYourestiny());
    //   }
    // });
  }
  unWait(BuildContext context, String stopId) {
    final socket = Provider.of<SocketService>(context, listen: false).socket;
    socket.emit('substractWait', stopId);
  }

  wait(BuildContext context, String stopId) {
    final socket = Provider.of<SocketService>(context, listen: false).socket;
    socket.emit('addWait', stopId);
  }
}
