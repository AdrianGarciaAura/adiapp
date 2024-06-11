import 'package:adiapp/model/ronda.dart';

//clase datos json ronda
class DatosRonda {
  String mensaje;
  Ronda dato;



  //constructor
  DatosRonda(this.mensaje,this.dato);

  //constructor a partir de un json
  factory DatosRonda.fromJson(Map<String, dynamic> json){
    print("descodificando inicio");
    Ronda dato = Ronda("", "", "", "", 0, "", "", "", "", 0, "", []);
    print("antes de ver mensaje");
    if(json["mensaje"] == 'ok') {
      print("antes de descodificar ronda");
      dato = Ronda.fromMap(json["dato"]);
    }
    print("devuelve resultado descodificacion");
    return DatosRonda(json["mensaje"], dato);
  }
}