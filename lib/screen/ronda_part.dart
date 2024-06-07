import 'dart:convert';
import 'package:adiapp/screen/usuario_rondas.dart';
import 'package:flutter/material.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/model/ronda.dart';
import 'package:http/http.dart' as http;
import '../model/datos_ronda.dart';
import '../model/participante.dart';
import 'anyadir_participante.dart';
import 'datos_amigo.dart';
import 'datos_ronda.dart';

class RondaParticipanteScreen extends StatefulWidget {
  Usuario usuario;
  Ronda ronda;
  RondaParticipanteScreen(this.usuario,this.ronda,{Key? key}) : super(key: key);

  @override
  State<RondaParticipanteScreen> createState() => _RondaParticipanteScreenState(usuario,ronda);
}

class _RondaParticipanteScreenState extends State<RondaParticipanteScreen> {
  Usuario usuario;
  Ronda ronda;
  _RondaParticipanteScreenState(this.usuario, this.ronda);

  @override
  Widget build(BuildContext context) {
    List<Participante> _data = ronda.participantes;
    return Scaffold(
        appBar: AppBar(
          title: Text('Participantes ' + ronda.nombre),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue.shade400,
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontSize: 24),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaScreen(usuario,ronda.id,ronda.nombre)));
              },
              icon: Icon(Icons.arrow_back,color: Colors.white),
            ),
            _botonModificar(context)
          ],
        ),
        body: ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, index) => _listItem(context, _data[index]),
            ),
    );
  }

  Widget _botonModificar(context){
    if(ronda.mail == usuario.mail){
      return IconButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> ParticipanteScreen(usuario,ronda)));
        },
        icon: Icon(Icons.add,color: Colors.white),
      );
    } else {
      return IconButton(
        onPressed: null,
        icon: Icon(Icons.add,color: Colors.blue.shade400),
      );
    }
  }

  Widget _listItem(BuildContext context, Participante element) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        tileColor: Colors.white,
        title: Text('${element.nombre}', style: TextStyle(
          color: Colors.teal, fontSize: 15.0,),),
        subtitle: Text('estado A.D.I: ${element.adi}', style: TextStyle(
          color: Colors.blue.shade400, fontSize: 10.0,),),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(20.0)
        ),
      ),
    );
  }
}