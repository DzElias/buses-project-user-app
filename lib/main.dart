import 'package:flutter/material.dart';
import 'package:medirutas/routes/routes.dart';
import 'package:provider/provider.dart';

import 'services/socket_service.dart';

void main() => runApp(MainActivity());

class MainActivity extends StatelessWidget {
  const MainActivity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          child: SizedBox(),
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
    );
    return MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => SocketService())],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Map",
          routes: appRoutes,
          initialRoute: 'loading',
        ));
  }
}
