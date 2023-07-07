import 'package:flutter/material.dart';
import 'package:me_voy_usuario/blocs/travel/travel_bloc.dart';
import 'package:provider/provider.dart';

class UnWaitButton extends StatelessWidget {
  const UnWaitButton({
    Key? key,
    required this.fabHeight,
  }) : super(key: key);

  final double fabHeight;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: fabHeight + 10,
        right: 10,
        child: ElevatedButton(
            onPressed: () {
              Provider.of<TravelBloc>(context, listen: false)
                  .add(UnWaitEvent(context));
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              primary: Colors.red,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Row(
                children: const [
                  Icon(Icons.close, color: Colors.white),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Cancelar espera',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
            )));
  }
}
