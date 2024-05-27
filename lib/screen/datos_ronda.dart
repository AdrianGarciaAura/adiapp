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
import 'anyadir_participante.dart';
import 'crear_ronda.dart';
import 'datos_amigo.dart';
import 'datos_usuario.dart';
import 'gestion_ronda.dart';


class RondaScreen extends StatelessWidget {
  Usuario usuario;
  String idRonda;
  String nombreRonda;
  RondaScreen(this.usuario,this.idRonda,this.nombreRonda,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ronda ' + nombreRonda),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> UsuRondasScreen(usuario)));
                }
            ),
          ],
        ),
        body: FutureBuilder<DatosRonda>(
          future: getRonda(idRonda),
          builder: (context, snapshot){
            if(snapshot.hasData){
              return _RondaScreenState(snapshot.data!,usuario);
            }else{
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
    );
  }

  Future<DatosRonda> getRonda(idRonda) async {
    final response = await http
        .get(Uri.parse('?action=getRonda&idronda='+idRonda));
    if (response.statusCode == 200) {
      return DatosRonda.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

}

class _RondaScreenState extends StatelessWidget {
  DatosRonda datosRonda;
  Usuario usuario;
  _RondaScreenState(this.datosRonda,this.usuario);

  @override
  Widget build(BuildContext context) {
    Ronda ronda = datosRonda.dato;
    List<Participante> _data = ronda.participantes;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(overflow: TextOverflow.ellipsis, 'ID: ${ronda.id}: ${ronda.nombre}',style: TextStyle(color: Colors.teal, fontSize: 15.0,)),
        Text(overflow: TextOverflow.ellipsis, 'Gestionador: ${ronda.gestionador}: ${ronda.mail}',style: TextStyle(color: Colors.blue.shade400, fontSize: 10.0,)),
        Text(overflow: TextOverflow.ellipsis, '${ronda.tipo}: ${(ronda.tipo == 'ADistancia') ? 'finaliza el '+ ronda.fechaMaxima : ronda.entrega}',style: TextStyle(color: Colors.blue.shade400, fontSize: 10.0,)),
        Text(overflow: TextOverflow.ellipsis, 'Num.Part: ${ronda.num},  ${ronda.dinero}€, Estado: ${ronda.estado}',style: TextStyle(color: Colors.blue.shade400, fontSize: 10.0,)),
        _botones(context,ronda),
        _botonAmigo(context,ronda),
        ListView.builder(
          itemCount: _data.length,
          itemBuilder: (context,index)=> _listItem(context,_data[index]),
        ),
      ],
    );
  }

  Widget _listItem(BuildContext context, Participante element){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        tileColor: Colors.white,
        title: Text('${element.nombre}', style: TextStyle(color: Colors.teal, fontSize: 15.0,),),
        subtitle: Text('estado A.D.I: ${element.adi}', style: TextStyle(color: Colors.blue.shade400, fontSize: 10.0,),),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(20.0)
        ),
      ),
    );
  }

  Widget _botones(context,ronda){
    if(ronda.mail == usuario.mail){
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Text('Configuracion ronda', style: TextStyle(color: Colors.blue, fontSize: 15.0,)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaGestionScreen(usuario,ronda)));
                }
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Text('Gestion participantes', style: TextStyle(color: Colors.blue, fontSize: 15.0,)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ParticipanteScreen(usuario,ronda)));
                }
            ),
          ),
        ],
      );
    } else {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('Configuracion ronda', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: null
      );
    }
  }

  Widget _botonAmigo(context,ronda){
    if(ronda.estado == "SorteoRealizado"){
      return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('Datos Amigo', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> AmigoScreen(usuario,ronda)));
          }
      );
    } else {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('Datos Amigo', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: null
      );
    }
  }
}