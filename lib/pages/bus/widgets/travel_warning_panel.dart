import 'package:flutter/material.dart';

class TravelWarningPanel extends StatelessWidget {
  const TravelWarningPanel({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 0,
        child: Container(
          color: Colors.green,
          height: 40,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Center(
              child: Text(message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18))),
        ));
  }
}
