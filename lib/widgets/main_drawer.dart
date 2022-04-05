import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      
                      child: Container(
                        margin: EdgeInsets.only(
                          top: 30,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                            image: AssetImage("assets/chofer.jpg"),
                            fit: BoxFit.cover)),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 15, bottom: 15),
                      child: Column(
                        children: [
                          Text(
                            "Carlos",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Rodriguez",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )),
                  ListTile(
                    leading:
                        Icon(Icons.map, color: Colors.green, size: 30),
                    title: Text(
                      "Mapa",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      if (ModalRoute.of(context)!.settings.name !=
                          'home') {
                        Navigator.pushReplacementNamed(
                            context, 'home');
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.phone,
                        color: Colors.blue, size: 30),
                    title: Text(
                      "Llamar por ayuda",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // if (ModalRoute.of(context)!.settings.name !=
                      //     'search-bus') {
                      //   Navigator.pushReplacementNamed(context, 'search-bus');
                      // } else {
                        Navigator.pop(context);
                      // }
                    },
                  ),
                 
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
