import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:me_voy_usuario/blocs/bus/bus_bloc.dart';
import 'package:me_voy_usuario/blocs/internet_connection/internet_connection_bloc.dart';
import 'package:me_voy_usuario/blocs/location_permissions/location_permission_bloc.dart';
import 'package:me_voy_usuario/blocs/map/map_bloc.dart';
import 'package:me_voy_usuario/blocs/stop/stop_bloc.dart';
import 'package:me_voy_usuario/blocs/stops_page_view/stops_page_view_bloc.dart';
import 'package:me_voy_usuario/blocs/travel/travel_bloc.dart';
import 'package:me_voy_usuario/blocs/user_location/user_location_bloc.dart';
import 'package:me_voy_usuario/firebase_options.dart';
import 'package:me_voy_usuario/pages/home/home_page.dart';
import 'package:me_voy_usuario/pages/location_perm/location_perm_page.dart';
import 'package:me_voy_usuario/pages/splash_page.dart';
import 'package:me_voy_usuario/services/location_permissions_service.dart';
import 'package:me_voy_usuario/services/socket_service.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData windowData =
        MediaQueryData.fromWindow(WidgetsBinding.instance.window);

    windowData = windowData.copyWith(
      textScaleFactor:
          windowData.textScaleFactor > 1.0 ? 1.0 : windowData.textScaleFactor,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SocketService()),
          BlocProvider(
              create: (_) =>
                  LocationPermissionBloc(GeolocatorPermissionService())
                    ..add(InitCheckingEvent())),
          BlocProvider(create: (_) => InternetConnectionBloc()),
          BlocProvider(create: (_) => UserLocationBloc()),
          BlocProvider(create: (_) => StopBloc()),
          BlocProvider(create: (_) => BusBloc()),
          BlocProvider(
            create: (_) => MapBloc(),
          ),
          BlocProvider(create: (_) => TravelBloc()),
          BlocProvider(create: (_) => StopsPageViewBloc(PageController())),
        ],
        child: MediaQuery(
            data: windowData,
            child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'MeVoy',
                initialRoute: 'splash',
                routes: {
                  'splash': (_) => const SplashPage(),
                  'location-perm': (_) => const LocationPermPage(),
                  'home': (_) => const HomePage(),
                })));
  }
}
