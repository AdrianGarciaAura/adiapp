import 'package:adiapp/model/ronda.dart';
import 'package:adiapp/model/amigo.dart';
import 'package:adiapp/model/usuario.dart';

class DatosAmigo {
  String mensaje;
  Amigo dato;




  DatosAmigo(this.mensaje,this.dato);

  factory DatosAmigo.fromJson(Map<String, dynamic> json){
    Amigo dato = Amigo("", "", "", 0, "");
    if(json["mensaje"] == 'ok') {
      dato = Amigo.fromMap(json["dato"]);
    }
    return DatosAmigo(json["mensaje"], dato);
  }
}