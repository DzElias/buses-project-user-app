
import 'dart:ui';

import 'package:flutter/material.dart';

const markerColor = Colors.blueAccent;

class UserLocationMarker extends AnimatedWidget {
  const UserLocationMarker(Animation<double> animation, {Key? key})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final value = (listenable as Animation<double>).value;
    final double newValue = lerpDouble(0.7, 1.0, value)!;
    const size = 25;
    return Center(
      child: Stack(
        children: [
          Center(
            child: Container(
              height: size * newValue,
              width: size * newValue,
              decoration: BoxDecoration(
                  color: markerColor.withOpacity(0.3), shape: BoxShape.circle),
            ),
          ),
          Center(
            child: Container(
              height: 15,
              width: 15,
              decoration:
                const BoxDecoration(color: markerColor, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}