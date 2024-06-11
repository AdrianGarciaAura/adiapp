import 'package:adiapp/model/ronda.dart';
//clase usuario
class Usuario {
  String mail;
  String nombre;
  String password;
  String bloqueado;
  String fecha;
  String direccion;
  String creacion;
  List<Ronda> rondas;



  //constructor
  Usuario(this.mail,this.nombre,this.password,this.bloqueado,this.fecha,this.direccion,this.creacion,this.rondas);

  //constructor a partir de un json
  factory Usuario.fromMap(Map<String,dynamic> map){
    List<dynamic> listRondas = map["rondas"];
    List<Ronda> rondas = listRondas.map((element) => Ronda.fromMapLite(element)).toList();
    return Usuario(map['mail'],
        map['nombre'],
        map['password'],
        map['bloqueado'],
        map['fecha'],
        map['direccion'],
        map['creacion'],rondas);
  }

  //metodo para formar una lista dinamica de un usuario
  static Map<String, dynamic> toJson(Usuario value) =>
      {'mail': value.mail, 'nombre': value.nombre, 'password': value.password,
        'bloqueado': value.bloqueado, 'fecha': value.fecha, 'direccion': value.direccion,
        'creacion': value.creacion, 'rondas': value.rondas};
}