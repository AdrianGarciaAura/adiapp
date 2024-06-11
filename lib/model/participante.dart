//clase participante
class Participante {
  String nombre;
  String mail;
  String adi;



  //constructor
  Participante(this.nombre,this.mail,this.adi);

  //constructor a partir de un json
  factory Participante.fromMap(Map<String,dynamic> map) => Participante(
      map['nombre'],
      map['mail'],
      map['adi']);
}