part of 'travel_bloc.dart';

abstract class TravelState extends Equatable {
  const TravelState();

  @override
  List<Object> get props => [];
}

class NoTravelingState extends TravelState {}

class WaitingState extends TravelState {
  const WaitingState(
      {required this.bus,
      required this.isHere,
      required this.stopsSelected,
      required this.destino});

  final Bus bus;
  final List<Stop> stopsSelected;
  final LatLng? destino;
  final bool isHere;

  WaitingState isHereEvent() {
    return WaitingState(
        bus: bus, stopsSelected: stopsSelected, destino: destino, isHere: true);
  }
}

// class IsTravelingState extends TravelState {
//   final Bus bus;
//   final LatLng? destino;
//   final List<Stop> stopsSelected;
//   final bool walkToYourDestination;


//   const IsTravelingState({this.walkToYourDestination = false, required this.bus, required this.stopsSelected, required this.destino });

//   IsTravelingState walkToYourestiny(){
//     return IsTravelingState(bus: bus, destino: destino, stopsSelected: stopsSelected, walkToYourDestination: true);
//   }

// }

