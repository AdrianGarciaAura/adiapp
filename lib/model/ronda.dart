import 'package:adiapp/model/participante.dart';

class Ronda {
  String id;
  String nombre;
  String gestionador;
  String mail;
  int num;
  String tipo;
  String fecha;
  String entrega;
  String fechaMaxima;
  int dinero;
  String estado;
  List<Participante> participantes;




  Ronda(this.id,this.nombre,this.gestionador,this.mail,this.num,
      this.tipo,this.fecha,this.entrega,this.fechaMaxima,this.dinero,this.estado,this.participantes);

  factory Ronda.fromMap(Map<String,dynamic> map){
    List<dynamic> list = map["participantes"];
    List<Participante> participantes = list.map((element) => Participante.fromMap(element)).toList();
    return Ronda(map['id'],
          map['nombre'],
          map['gestionador'],
          map['mail'],
          map['num'],
          map['tipo'],
          map['fecha'],
          map['entrega'],
          map['fechaMaxima'],
          map['dinero'],
          map['estado'],participantes);
  }
}