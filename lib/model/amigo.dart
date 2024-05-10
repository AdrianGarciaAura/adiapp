class Amigo {
  String nombre;
  String nombreRonda;
  String direccion;
  int dinero;
  String envio;




  Amigo(this.nombre,this.nombreRonda,this.direccion,this.dinero,this.envio);

  factory Amigo.fromMap(Map<String,dynamic> map) => Amigo(
      map['nombre'],
      map['nombreRonda'],
      map['direccion'],
      map['dinero'],
      map['envio']);
}