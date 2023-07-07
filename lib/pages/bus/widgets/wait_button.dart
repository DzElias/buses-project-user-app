import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:me_voy_usuario/blocs/travel/travel_bloc.dart';
import 'package:me_voy_usuario/blocs/user_location/user_location_bloc.dart';
import 'package:me_voy_usuario/pages/bus/bus_page.dart';
import 'package:me_voy_usuario/utils/matrix.dart';

import 'package:provider/provider.dart';

class WaitButton extends StatelessWidget {
  const WaitButton({
    Key? key,
    required this.parent,
    required this.fabHeight,
  }) : super(key: key);

  final BusPage parent;
  final double fabHeight;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserLocationBloc, UserLocationState>(
      builder: (context, userLocationState) {
        if (userLocationState is UserLocationLoaded) {
          LatLng userLocation =
              LatLng(userLocationState.latitude, userLocationState.longitude);
          LatLng firsStopLocation = LatLng(parent.stopSelected[0].latitude,
              parent.stopSelected[0].longitude);
          return Positioned(
              bottom: fabHeight + 10,
              right: 10,
              child: ElevatedButton(
                  onPressed: (Matrix().calculateDistanceInMeters(
                              userLocation, firsStopLocation) >
                          150)
                      ? null
                      : () {
                          Provider.of<TravelBloc>(context, listen: false)
                              .add(WaitEvent(
                            context,
                            bus: parent.bus,
                            stopsSelected: parent.stopSelected,
                            destino: null,
                          ));
                        },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    primary: Colors.blueAccent,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Row(
                      children: const [
                        Icon(Icons.hourglass_empty, color: Colors.white),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Esperar aqui',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  )));
        }
        return Container();
      },
    );
  }
}
