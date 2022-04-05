import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medirutas/bloc/my_location/my_location_bloc.dart';
import 'package:medirutas/bloc/stops/stops_bloc.dart';

import 'package:medirutas/routes/routes.dart';
import 'package:medirutas/services/stops_service.dart';
import 'package:provider/provider.dart';

import 'services/socket_service.dart';

void main() {
  runApp(const MainActivity());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MainActivity extends StatelessWidget {
  const MainActivity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          child: const SizedBox(),
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
    );
    return MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => SocketService()),
        Provider(create: (_) => StopsBloc(stopService: StopService()),),
        Provider(create: (_) => MyLocationBloc())
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Map",
          routes: appRoutes,
          initialRoute: 'loading',
        ));//
  }
}
