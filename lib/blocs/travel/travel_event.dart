part of 'travel_bloc.dart';

abstract class TravelEvent extends Equatable {
  const TravelEvent();

  @override
  List<Object> get props => [];
}

class WaitEvent extends TravelEvent {
  final Bus bus;
  final List<Stop> stopsSelected;
  final LatLng? destino;
  final BuildContext context;

  const WaitEvent(this.context,
      {required this.bus, required this.stopsSelected, this.destino});
}

class IsHereEvent extends TravelEvent {}

// class IsTravelingEvent extends TravelEvent {
//   final BuildContext context;

//   const IsTravelingEvent({required this.context});
// }

class EndTravelEvent extends TravelEvent {
  final BuildContext context;

  const EndTravelEvent({required this.context});
  //TODO:  big data
}

class UnWaitEvent extends TravelEvent {
  final BuildContext context;

  const UnWaitEvent(this.context);
}

// class WalkToYourDestinationEvent extends TravelEvent {}
