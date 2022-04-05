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
        required this.direccion,
        required this.imagen,
        required this.v,
        required this.esperas,
        
    });

    String id;
    String titulo;
    double latitud;
    double longitud;
    String direccion;
    String imagen;
    int v;
    int esperas;
    

    factory Stop.fromJson(Map<String, dynamic> json) => Stop(
        id: json["_id"],
        titulo: json["titulo"],
        latitud: json["latitud"].toDouble(),
        longitud: json["longitud"].toDouble(),
        direccion: json["direccion"],
        imagen: json["imagen"],
        v: json["__v"],
        esperas: json["esperas"],
        
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "titulo": titulo,
        "latitud": latitud,
        "longitud": longitud,
        "direccion": direccion,
        "imagen": imagen,
        "__v": v,
        "esperas": esperas,
        
    };
}
