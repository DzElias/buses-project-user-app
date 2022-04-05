part of 'stops_bloc.dart';

@immutable
class StopsState  {
  final List<Stop> stops;

  const StopsState({
    this.stops = const [],
  });

  StopsState copyWith({
    List<Stop>? stops,
  }) =>
      StopsState(
        stops: stops ?? this.stops,
      );

}
