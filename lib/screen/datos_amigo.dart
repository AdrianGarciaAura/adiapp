import 'dart:convert';
import 'dart:js';

import 'package:adiapp/screen/usuario_rondas.dart';
import 'package:flutter/material.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/model/ronda.dart';
import 'package:adiapp/model/amigo.dart';
import 'package:adiapp/screen/login.dart';
import 'package:http/http.dart' as http;
import '../model/datos_amigo.dart';
import '../model/datos_ronda.dart';
import '../model/participante.dart';
import 'crear_ronda.dart';
import 'datos_ronda.dart';
import 'datos_usuario.dart';


class AmigoScreen extends StatelessWidget {
  Usuario usuario;
  Ronda ronda;
  AmigoScreen(this.usuario,this.ronda,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ronda ' + ronda.nombre),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade400,
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontSize: 24),
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Volver', style: TextStyle(color: Colors.blue, fontSize: 15.0,)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaScreen(usuario,ronda.id,ronda.nombre)));
              }
          ),
        ],
      ),
      body: FutureBuilder<DatosAmigo>(
        future: getAmigo(ronda.id,usuario.mail),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return _AmigoScreenState(snapshot.data!,usuario,ronda);
          }else{
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<DatosAmigo> getAmigo(idRonda,mail) async {
    final response = await http
        .get(Uri.parse('?action=getAmigo&idronda='+idRonda+'&mail='+mail));
    if (response.statusCode == 200) {
      return DatosAmigo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

}

class _AmigoScreenState extends StatelessWidget {
  DatosAmigo datosAmigo;
  Usuario usuario;
  Ronda ronda;
  _AmigoScreenState(this.datosAmigo,this.usuario,this.ronda);

  @override
  Widget build(BuildContext context) {
    if(datosAmigo.mensaje == 'ok'){
      Amigo amigo = datosAmigo.dato;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(overflow: TextOverflow.ellipsis, 'A.D.I a regalar: ${amigo.nombre}',style: TextStyle(color: Colors.teal, fontSize: 15.0,)),
          Text(overflow: TextOverflow.ellipsis, 'Ronda: ${amigo.nombreRonda}, ${amigo.dinero}€',style: TextStyle(color: Colors.blue.shade400, fontSize: 10.0,)),
          Text(overflow: TextOverflow.ellipsis, 'Direccion: ${amigo.direccion}',style: TextStyle(color: Colors.blue.shade400, fontSize: 10.0,)),
          Text(overflow: TextOverflow.ellipsis, 'Estado del envio: ${amigo.envio}',style: TextStyle(color: Colors.blue.shade400, fontSize: 10.0,)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: Text('Confirmar Envio a ${amigo.nombre}', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
              onPressed: () async{
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                );
                String mensaje = await confEnv(ronda.id, usuario.mail);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.yellow),
                );
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: const Text('Confirmar Entrega', style: TextStyle(color: Colors.blue, fontSize: 15.0,)),
                    onPressed: () async{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                      );
                      String mensaje = await confEnt(ronda.id, usuario.mail);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.yellow),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> AmigoScreen(usuario,ronda)));
                    }
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: const Text('Banear A.D.I', style: TextStyle(color: Colors.blue, fontSize: 15.0,)),
                    onPressed: () async{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                      );
                      String mensaje = await baneo(usuario.mail,ronda.id );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.yellow),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> AmigoScreen(usuario,ronda)));
                    }
                ),
              ),
            ],
          )
        ],
      );
    } else {
      return Text(overflow: TextOverflow.ellipsis, 'No participas en la ronda',style: TextStyle(color: Colors.teal, fontSize: 15.0,));
    }

  }



  Future<String> confEnv(idRonda,mail) async {
    final response = await http.get(Uri.parse('?action=login&idronda='+idRonda+'&mail='+mail));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return json["mensaje"];
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

  Future<String> confEnt(idRonda,mail) async {
    final response = await http.get(Uri.parse('?action=login&idronda='+idRonda+'&mail='+mail));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return json["mensaje"];
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

  Future<String> baneo(mail,idRonda) async {
    final response = await http.get(Uri.parse('?action=login&mail='+mail+'&idronda='+idRonda));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return json["mensaje"];
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }
}