// To parse this JSON data, do
//
//     final stop = stopFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Stop stopFromJson(String str) => Stop.fromJson(json.decode(str));

String stopToJson(Stop data) => json.encode(data.toJson());

class Stop {
    Stop({
        required this.id,
        required this.titulo,
        required this.latitud,
        required this.longitud,
        required this.esperas,
        
    });

    String id;
    String titulo;
    double latitud;
    double longitud;
    int esperas;
    

    factory Stop.fromJson(Map<String, dynamic> json) => Stop(
        id: json["_id"],
        titulo: json["titulo"],
        latitud: json["latitud"].toDouble(),
        longitud: json["longitud"].toDouble(),
        esperas: json["esperas"],
        
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "titulo": titulo,
        "latitud": latitud,
        "longitud": longitud,
        "esperas": esperas,
        
    };
}
