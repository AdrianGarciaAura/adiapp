import 'package:adiapp/model/ronda.dart';
import 'package:adiapp/model/amigo.dart';

class Usuario {
  String mail;
  String nombre;
  String password;
  String bloqueado;
  String fecha;
  String direccion;
  String creacion;
  List<Ronda> rondas;
  List<Amigo> amigos;




  Usuario(this.mail,this.nombre,this.password,this.bloqueado,this.fecha,this.direccion,this.creacion,this.rondas,this.amigos);

  factory Usuario.fromMap(Map<String,dynamic> map){
    List<dynamic> listRondas = map["rondas"];
    List<Ronda> rondas = listRondas.map((element) => Ronda.fromMap(element)).toList();
    List<dynamic> listAmigos = map["amigos"];
    List<Amigo> amigos = listAmigos.map((element) => Amigo.fromMap(element)).toList();
    return Usuario(map['mail'],
        map['nombre'],
        map['password'],
        map['bloqueado'],
        map['fecha'],
        map['direccion'],
        map['creacion'],rondas,amigos);
  }
}