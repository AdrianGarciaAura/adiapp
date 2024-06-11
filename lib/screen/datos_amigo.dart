import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/model/ronda.dart';
import 'package:adiapp/model/amigo.dart';
import 'package:http/http.dart' as http;
import '../model/datos_amigo.dart';
import 'datos_ronda.dart';
import 'ronda_part.dart';

const String _link = 'https://script.google.com/macros/s/AKfycbxXxRI_y1l6lPxXHfBURrQJbVE3pVbV81JgYwRFd8R8cprgfjAQlOM0Tj9n52Fuoe8k/exec';

//pantalla de amigo de la ronda
class AmigoScreen extends StatelessWidget {
  Usuario usuario;
  Ronda ronda;
  AmigoScreen(this.usuario,this.ronda,{Key? key}) : super(key: key);

  //se construye los widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appbar con un boton de volver
      appBar: AppBar(
        title: Text('Ronda ' + ronda.nombre),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade400,
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontSize: 24),
        actions: [
          IconButton(
            onPressed: () {
              //se vuelve a los datos de la ronda
              Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaScreen(usuario,ronda.id,ronda.nombre)));
            },
            icon: Icon(Icons.arrow_back,color: Colors.white),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          //se devuelve los datos del amigo cuando se reciban los datos de la api
          FutureBuilder<DatosAmigo>(
            future: getAmigo(ronda.id,usuario.mail),
            builder: (context, snapshot){
              if(snapshot.hasData){
                return _AmigoScreenState(snapshot.data!,usuario,ronda);
              }else{
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      )
    );
  }

  //llamada a la api para recibir el amigo de la ronda
  Future<DatosAmigo> getAmigo(idRonda,mail) async {
    final response = await http
        .get(Uri.parse(_link+'?action=getAmigo&idronda='+idRonda+'&mail='+mail));
    if (response.statusCode == 200) {
      return DatosAmigo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

}

//los datos del amigo
class _AmigoScreenState extends StatelessWidget {
  DatosAmigo datosAmigo;
  Usuario usuario;
  Ronda ronda;
  _AmigoScreenState(this.datosAmigo,this.usuario,this.ronda);

  //se construye la pantalla segun los datos recibidos
  @override
  Widget build(BuildContext context) {
    if(datosAmigo.mensaje == 'ok'){
      Amigo amigo = datosAmigo.dato;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(overflow: TextOverflow.ellipsis, 'A.D.I a regalar: ${amigo.nombre}',style: TextStyle(color: Colors.teal, fontSize: 20.0,)),
          Text(overflow: TextOverflow.ellipsis, 'Ronda: ${amigo.nombreRonda}, ${amigo.dinero}€',style: TextStyle(color: Colors.blue.shade400, fontSize: 20.0,)),
          _aDistancia(context,amigo)
        ],
      );
    } else {
      return Text(overflow: TextOverflow.ellipsis, 'No participas en la ronda',style: TextStyle(color: Colors.teal, fontSize: 15.0,));
    }

  }

  //se construye los datos y botones relacionados con una ronda a distancia
  Widget _aDistancia(context,amigo) {
    if(ronda.tipo == 'ADistancia'){
      return Form(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(overflow: TextOverflow.ellipsis, 'Direccion: ${amigo.direccion}',style: TextStyle(color: Colors.blue.shade400, fontSize: 20.0,)),
                Text(overflow: TextOverflow.ellipsis, 'Estado del envio: ${amigo.envio}',style: TextStyle(color: Colors.blue.shade400, fontSize: 20.0,)),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text('Confirmar Envio a ${amigo.nombre}', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
                    //metodo para confirmar un envio
                    onPressed: () async{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                      );
                      String mensaje = await confEnv(ronda.id, usuario.mail);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                      );
                      //se recarga la pagina
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> AmigoScreen(usuario,ronda)));
                    }
                ),
                Text(overflow: TextOverflow.ellipsis, 'Estado de tu A.D.I: ${ronda.participantes.singleWhere((participante) => participante.mail == usuario.mail).adi}',style: TextStyle(color: Colors.teal, fontSize: 15.0,)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text('Confirmar Entrega', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
                          //metodo para confirmar una entrega
                          onPressed: () async{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                            );
                            String mensaje = await confEnt(ronda.id, usuario.mail);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                            );
                            //se recarga la pagina
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> AmigoScreen(usuario,ronda)));
                          }
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text('Banear A.D.I', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
                          //metodo para banear a tu adi
                          onPressed: () async{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                            );
                            String mensaje = await baneo(usuario.mail,ronda.id );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                            );
                            //se recarga la pagina
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> AmigoScreen(usuario,ronda)));
                          }
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
      );
    } else {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('Solo a distancia', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: null
      );
    }


  }



  //llamada a la api para confirmar envio
  Future<String> confEnv(idRonda,mail) async {
    final response = await http.get(Uri.parse(_link+'?action=confirmarEnvio&idronda='+idRonda+'&mail='+mail));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return json["mensaje"];
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

  //llamada a la api para confirmar entrega
  Future<String> confEnt(idRonda,mail) async {
    final response = await http.get(Uri.parse(_link+'?action=confirmarEntrega&idronda='+idRonda+'&mail='+mail));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return json["mensaje"];
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

  //llamada a la api para banear a tu adi
  Future<String> baneo(mail,idRonda) async {
    final response = await http.get(Uri.parse(_link+'?action=baneo&mail='+mail+'&idronda='+idRonda));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return json["mensaje"];
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }
}