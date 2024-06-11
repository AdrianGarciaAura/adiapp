import 'package:adiapp/model/participante.dart';

//clase ronda
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



  //constructor
  Ronda(this.id,this.nombre,this.gestionador,this.mail,this.num,
      this.tipo,this.fecha,this.entrega,this.fechaMaxima,this.dinero,this.estado,this.participantes);

  //constructor a partir de un json
  factory Ronda.fromMap(Map<String,dynamic> map){
    print("dr inicio");
    List<dynamic> list = map["participantes"];
    List<Participante> participantes = list.map((element) => Participante.fromMap(element)).toList();
    print("dr antes final");
    return Ronda(map['id'].toString(),
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

  //constructor de una version con pocos datos a partir de un json
  factory Ronda.fromMapLite(Map<String,dynamic> map){
    return Ronda(map['id'].toString(),
        map['nombre'],
        map['gestionador'], "",
        map['num'],
        map['tipo'], "", "", "", 0,
        map['estado'],[]);
  }

  //metodo para formar una lista dinamica de una ronda
  static Map<String, dynamic> toJson(Ronda value) =>
      {'id': value.id, 'nombre': value.nombre, 'gestionador': value.gestionador, 'mail': value.mail, 'num': value.num,
        'tipo': value.tipo, 'fecha': value.fecha, 'entrega': value.entrega,
        'fechaMaxima': value.fechaMaxima, 'dinero': value.dinero, 'estado': value.estado, 'participantes': value.participantes
      };
}