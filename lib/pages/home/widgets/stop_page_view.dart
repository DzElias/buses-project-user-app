import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:me_voy_usuario/blocs/stop/stop_bloc.dart';
import 'package:me_voy_usuario/blocs/stops_page_view/stops_page_view_bloc.dart';
import 'package:me_voy_usuario/blocs/user_location/user_location_bloc.dart';
import 'package:me_voy_usuario/models/stop.dart';
import 'package:me_voy_usuario/pages/stop/stop_page.dart';
import 'package:me_voy_usuario/utils/matrix.dart';
import 'package:provider/provider.dart';

class StopsPageView extends StatefulWidget {
  const StopsPageView({
    Key? key,
  }) : super(key: key);

  @override
  State<StopsPageView> createState() => _StopsPageViewState();
}

class _StopsPageViewState extends State<StopsPageView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserLocationBloc, UserLocationState>(
      builder: (context, userLocationState) {
        return BlocBuilder<StopBloc, StopState>(
          builder: (context, stopstate) {
            if (userLocationState is UserLocationLoaded) {
              if (stopstate is StopsLoadedState) {
                List<Stop> stops = stopstate.stops;
                LatLng userLocation = LatLng(
                    userLocationState.latitude, userLocationState.longitude);
                stops.sort(((a, b) {
                  LatLng aLatLng = LatLng(a.latitude, a.longitude);
                  LatLng bLatLng = LatLng(b.latitude, b.longitude);

                  return Matrix()
                      .calculateDistanceInMeters(aLatLng, userLocation)
                      .compareTo(Matrix()
                          .calculateDistanceInMeters(bLatLng, userLocation));
                }));
                return Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overScroll) {
                        overScroll.disallowIndicator();
                        return true;
                      },
                      child: PageView.builder(
                        controller: Provider.of<StopsPageViewBloc>(context,
                                listen: false)
                            .pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: stops.length,
                        itemBuilder: (context, i) {
                          final stop = stops[i];
                          return StopAdd(
                              stop: stop,
                              userLocation: userLocation,
                              isNearest: i == 0);
                        },
                      ),
                    ));
              }
            }
            return Container();
          },
        );
      },
    );
  }
}

class StopAdd extends StatefulWidget {
  const StopAdd(
      {Key? key,
      required this.stop,
      required this.userLocation,
      required this.isNearest})
      : super(key: key);

  final Stop stop;
  final LatLng userLocation;
  final bool isNearest;

  @override
  State<StopAdd> createState() => _StopAddState();
}

class _StopAddState extends State<StopAdd> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => StopPage(stop: widget.stop)));
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.isNearest
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(3)),
                              padding: const EdgeInsets.all(6),
                              child: const Text('Parada mas cercana',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)))
                        ],
                      )
                    : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Image(
                          image: AssetImage('assets/images/stop.png'),
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.stop.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.directions_walk,
                                    color: Colors.blue, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  Matrix().calculateDistanceString(
                                      LatLng(widget.stop.latitude,
                                          widget.stop.longitude),
                                      widget.userLocation),
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                    '(${Matrix().calculateTime(widget.stop.id, widget.userLocation, context, false)})',
                                    style:
                                        const TextStyle(color: Colors.black54))
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    Row(children: const [
                      Text('¡Ir allá!',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward, color: Colors.blue)
                    ])
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
