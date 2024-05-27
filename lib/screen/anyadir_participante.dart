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
import '../model/partCompleto.dart';
import '../model/participante.dart';
import 'crear_ronda.dart';
import 'datos_amigo.dart';
import 'datos_ronda.dart';
import 'datos_usuario.dart';

class ParticipanteScreen extends StatefulWidget {
  Usuario usuario;
  Ronda ronda;
  ParticipanteScreen(this.usuario,this.ronda,{Key? key}) : super(key: key);

  @override
  State<ParticipanteScreen> createState() => _ParticipanteScreenState(usuario,ronda);
}

class _ParticipanteScreenState extends State<ParticipanteScreen> {
  Usuario usuario;
  Ronda ronda;
  String _mail = "";
  String _nombre = "";
  final _formKey = GlobalKey<FormState>();

  _ParticipanteScreenState(this.usuario, this.ronda);

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
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Text('Volver', style: TextStyle(color: Colors.blue, fontSize: 15.0,)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaScreen(usuario,ronda.id,ronda.nombre)));
                }
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _nombreInput(),
                      _eMailInput(),
                      Text(overflow: TextOverflow.ellipsis, 'Para añadir o eliminar algun participante, poner sus datos',style: TextStyle(color: Colors.blue.shade400, fontSize: 10.0,)),
                      _botones(context),
                    ],
                  ),
                )
            ),
            ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, index) => _listItem(context, _data[index]),
            ),
          ],
        )
    );
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

  Widget _botones(context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Text('Añadir participante', style: TextStyle(
                  color: Colors.blue, fontSize: 15.0,)),
                onPressed: () async{
                  if(_formKey.currentState!.validate()){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                    );
                    ParticipanteCompl part = ParticipanteCompl(_nombre,_mail,'','','','nulo','no seleccionado');
                    String mensaje = await anyadirParticipante(part, ronda.id);
                    if(mensaje == "OK"){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('participante añadido correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaScreen(usuario,ronda.id,ronda.nombre)));
                    } else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error, participante incorrecto', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                    );
                  }
                }
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Text('Eliminar articipante', style: TextStyle(
                  color: Colors.blue, fontSize: 15.0,)),
                onPressed: () async{
                  if(_formKey.currentState!.validate()){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                    );
                    ParticipanteCompl part = ParticipanteCompl(_nombre,_mail,'','','','nulo','no seleccionado');
                    String mensaje = await deleteParticipante(part, ronda.id);
                    if(mensaje == "OK"){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('participante eliminado correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaScreen(usuario,ronda.id,ronda.nombre)));
                    } else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error, participante incorrecto', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                    );
                  }
                }
            ),
          ),
        ],
      );

  }

  Widget _eMailInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Mail Participante',
          hintText: 'nombre@mail',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Mail vacio';

          }
          if(!value.contains('@')){
            return 'Mail incorrecto';

          }
          setState(()  {
            _mail = value;
          });
          return null;
        },
      ),
    );
  }

  Widget _nombreInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Nombre Participante',
          hintText: 'nombre participante a añadir',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Nombre vacio';
          }
          setState(()  {
            _nombre = value;
          });
          return null;
        },
      ),
    );
  }

  Future<String> anyadirParticipante(ParticipanteCompl participante,String idRonda) async {
    final response = await http.post(
      Uri.parse('?action=postParticipante&idronda='+idRonda),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, ParticipanteCompl>{
        'participante': participante,
      }),
    );

    if (response.statusCode == 201) {
      Map<String, dynamic> json = jsonDecode(response.body);
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return json["mensaje"];
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Fallo al acceder a la api');
    }
  }

  Future<String> deleteParticipante(ParticipanteCompl participante,String idRonda) async {
    final response = await http.post(
      Uri.parse('?action=deleteParticipante&idronda='+idRonda),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, ParticipanteCompl>{
        'participante': participante,
      }),
    );

    if (response.statusCode == 201) {
      Map<String, dynamic> json = jsonDecode(response.body);
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return json["mensaje"];
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Fallo al acceder a la api');
    }
  }
}