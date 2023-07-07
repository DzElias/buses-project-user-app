part of 'stops_page_view_bloc.dart';

abstract class StopsPageViewEvent extends Equatable {
  const StopsPageViewEvent();

  @override
  List<Object> get props => [];
}

class AnimateToPageEvent extends StopsPageViewEvent {
  final int page;

  const AnimateToPageEvent(this.page);
}
