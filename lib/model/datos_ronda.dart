import 'package:adiapp/model/ronda.dart';

class DatosRonda {
  String mensaje;
  Ronda dato;




  DatosRonda(this.mensaje,this.dato);

  factory DatosRonda.fromJson(Map<String, dynamic> json){
    Ronda dato = Ronda.fromMap(json["dato"]);
    return DatosRonda(json["mensaje"], dato);
  }
}