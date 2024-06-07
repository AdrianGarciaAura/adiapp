import 'package:adiapp/model/usuario.dart';

class DatosUsuario {
  String mensaje;
  Usuario dato;




  DatosUsuario(this.mensaje,this.dato);

  factory DatosUsuario.fromJson(Map<String, dynamic> json){
    Usuario dato = Usuario("", "", "", "", "", "", "", []);
    if(json["mensaje"] == 'ok') {
      dato = Usuario.fromMap(json["dato"]);
    }
    return DatosUsuario(json["mensaje"], dato);

  }
}