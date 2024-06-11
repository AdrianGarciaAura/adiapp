//clase participante completo
class ParticipanteCompl {
  String nombre;
  String mail;
  String direccion;
  String amigo;
  String enviar;
  String estado;
  String adi;



  //constructor
  ParticipanteCompl(this.nombre,this.mail,this.direccion,this.amigo,this.enviar,this.estado,this.adi);

  //metodo para formar una lista dinamica de un participante
  static Map<String, dynamic> toJson(ParticipanteCompl value) =>
      {'nombre': value.nombre, 'mail': value.mail,'direccion': value.direccion,
        'AMIGO': value.amigo, 'enviar': value.enviar, 'estado': value.estado, 'adi': value.adi};
}