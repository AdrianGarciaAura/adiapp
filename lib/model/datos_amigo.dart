import 'package:adiapp/model/amigo.dart';

//clase datos amigo de un json
class DatosAmigo {
  String mensaje;
  Amigo dato;



  //constructor
  DatosAmigo(this.mensaje,this.dato);

  //constructor a partir de un json
  factory DatosAmigo.fromJson(Map<String, dynamic> json){
    Amigo dato = Amigo("", "", "", 0, "");
    if(json["mensaje"] == 'ok') {
      dato = Amigo.fromMap(json["dato"]);
    }
    return DatosAmigo(json["mensaje"], dato);
  }
}