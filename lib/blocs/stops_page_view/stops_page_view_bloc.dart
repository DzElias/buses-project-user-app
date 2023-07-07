// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'stops_page_view_event.dart';
part 'stops_page_view_state.dart';

class StopsPageViewBloc extends Bloc<StopsPageViewEvent, StopsPageViewState> {
  PageController pageController;
  StopsPageViewBloc(
    this.pageController,
  ) : super(StopsPageViewInitial()) {
    on<AnimateToPageEvent>((event, emit) {
      pageController.animateToPage(
        event.page, 
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeOut
      );
    });
  }
}
