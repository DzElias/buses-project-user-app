import 'package:flutter/material.dart';

import 'package:medirutas/routes/routes.dart';

void main() => runApp( MainActivity());

class MainActivity extends StatelessWidget {
  const MainActivity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Map",
      routes: appRoutes,
      initialRoute: 'loading',
    );
  }
}
