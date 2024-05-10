class Participante {
  String nombre;
  String mail;
  String adi;




  Participante(this.nombre,this.mail,this.adi);

  factory Participante.fromMap(Map<String,dynamic> map) => Participante(
      map['nombre'],
      map['mail'],
      map['adi']);
}