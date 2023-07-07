import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:me_voy_usuario/blocs/internet_connection/internet_connection_bloc.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar(this.title,
      {Key? key,
      required this.centerTitle,
      required this.backgroundColor,
      required this.elevation,
      required this.goBack})
      : preferredSize = const Size.fromHeight(50.0),
        super(key: key);

  final bool centerTitle;
  final String title;
  final Color backgroundColor;
  final double elevation;
  final bool goBack;
  final Size preferredSize;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isConnected = true;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: _isConnected ? widget.backgroundColor : Colors.red,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light),
      automaticallyImplyLeading: (_isConnected && widget.goBack),
      backgroundColor: _isConnected ? widget.backgroundColor : Colors.red,
      elevation: widget.elevation,
      centerTitle: widget.centerTitle,
      title: BlocBuilder<InternetConnectionBloc, InternetConnectionState>(
        builder: (context, state) {
          if (state is InternetConnectionDisabled) {
            Future.delayed(Duration.zero).then((value) {
              setState(() {
                _isConnected = false;
              });
            });
            return const Text('No tienes conexion a internet',
                style: TextStyle(color: Colors.white, fontSize: 18));
          } else {
            Future.delayed(Duration.zero).then((value) {
              setState(() {
                _isConnected = true;
              });
            });
            return Text(
              widget.title,
              style: const TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.bold),
            );
          }
        },
      ),
    );
  }
}
