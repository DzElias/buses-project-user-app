import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:me_voy_usuario/blocs/location_permissions/location_permission_bloc.dart';
import 'package:me_voy_usuario/pages/location_perm/widgets/request_permission_button.dart';
import 'package:provider/provider.dart';

class LocationPermPage extends StatefulWidget {
  const LocationPermPage({Key? key}) : super(key: key);

  @override
  State<LocationPermPage> createState() => _LocationPermPageState();
}

class _LocationPermPageState extends State<LocationPermPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<LocationPermissionBloc>(context, listen: false)
          .add(InitCheckingEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
              image: AssetImage('assets/images/undraw_map_location.png'),
              width: 300,
              height: 300),
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              children: const [
                Text('¿Dónde te encuentras?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(
                  height: 20,
                ),
                Text("Configura tu ubicacion para que podamos",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54)),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "brindarte una mejor experiencia",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54),
                ),
              ],
            ),
          ),
          BlocBuilder<LocationPermissionBloc, LocationPermissionState>(
            builder: (context, state) {
              if (state
                  is LocationPermissionIsGrantedAndLocationIsEnabledState) {
                Future.delayed(Duration.zero, () {
                  Navigator.pushReplacementNamed(context, 'home');
                });
              }
              ;
              return const RequestPermissionButton();
            },
          ),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
