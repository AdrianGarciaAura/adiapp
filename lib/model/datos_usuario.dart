import 'package:adiapp/model/usuario.dart';

//clase datos usuario
class DatosUsuario {
  String mensaje;
  Usuario dato;



  //constructor
  DatosUsuario(this.mensaje,this.dato);

  //constructor a partir de un json
  factory DatosUsuario.fromJson(Map<String, dynamic> json){
    Usuario dato = Usuario("", "", "", "", "", "", "", []);
    if(json["mensaje"] == 'ok') {
      dato = Usuario.fromMap(json["dato"]);
    }
    return DatosUsuario(json["mensaje"], dato);

  }
}