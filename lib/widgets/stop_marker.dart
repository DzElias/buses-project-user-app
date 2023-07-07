import 'package:flutter/material.dart';

const markerSizeExpanded = 60.0;
const markerSizeShrinked = 40.0;

class StopMarker extends StatelessWidget {
  const StopMarker({Key? key, this.selected = false}) : super(key: key);
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final size = selected ? markerSizeExpanded : markerSizeShrinked;
    return Center(
        child: AnimatedContainer(
            height: size,
            width: size,
            duration: const Duration(milliseconds: 300),
            child: const Image(image: AssetImage('assets/images/stop.png'))));
  }
}
