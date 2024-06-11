//clase amigo
class Amigo {
  String nombre;
  String nombreRonda;
  String direccion;
  int dinero;
  String envio;



  //constructor
  Amigo(this.nombre,this.nombreRonda,this.direccion,this.dinero,this.envio);

  //constructor a partir de un json
  factory Amigo.fromMap(Map<String,dynamic> map) => Amigo(
      map['nombre'],
      map['nombreRonda'],
      map['direccion'],
      map['dinero'],
      map['envio']);
}