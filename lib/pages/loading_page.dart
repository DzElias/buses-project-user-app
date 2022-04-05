import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool deniedForever = false;

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  late bool serviceEnabled;
  late LocationPermission permission;
  bool permissionStatus = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(child: CircularProgressIndicator()),
          permissionStatus
              ? const SizedBox()
              : Column(
                  children: [
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: const Offset(
                                  0, -3), // changes position of shadow
                            ),
                          ]),
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 50, top: 30),
                      child: Center(
                        child: Column(
                          children: [
                            const Text(
                              'Configura tu ubicacion para utilizar la app',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blueAccent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              child: const Center(
                                child: Text('Permitir acceso a ubicacion',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold)),
                              ),
                              onPressed: () async {
                                deniedForever
                                    ? onDeniedForever()
                                    : checkPermission();
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )
        ],
      ),
    );
  }

  //Verifica el acceso a la ubicacion del
  checkPermission() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Geolocator.openLocationSettings();
      return setState(() {
        permissionStatus = false;
      });
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return setState(() {
          permissionStatus = false;
        });
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      return setState(() {
        permissionStatus = false;
        deniedForever = true;
      });
    }

    Navigator.pushReplacementNamed(context, 'choice_bus');
  }

  onDeniedForever() async {
    Fluttertoast.showToast(
      msg: "Para continuar, de permiso para acceder a su ubicacion",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
    );
    await Geolocator.openAppSettings();
    checkPermission();
  }
}
