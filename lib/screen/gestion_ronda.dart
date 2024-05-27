import 'dart:ffi';

import 'package:adiapp/model/participante.dart';
import 'package:adiapp/screen/usuario_rondas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/model/ronda.dart';
import 'package:adiapp/model/amigo.dart';
import 'package:adiapp/screen/login.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'datos_ronda.dart';

class RondaGestionScreen extends StatefulWidget {
  Usuario usuario;
  Ronda ronda;
  RondaGestionScreen(this.usuario,this.ronda,{Key? key}) : super(key: key);

  @override
  State<RondaGestionScreen> createState() => _RondaGestionScreenState(usuario,ronda,DateTime.parse(ronda.fechaMaxima));
}

class _RondaGestionScreenState extends State<RondaGestionScreen> {
  Usuario usuario;
  Ronda ronda ;
  String _nombre = "";
  DateTime _fechaMaxima ;
  String _entrega = "";
  String _dinero = "";

  final _formKey = GlobalKey<FormState>();

  _RondaGestionScreenState(this.usuario, this.ronda, this._fechaMaxima);

  Widget _nombreInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: TextEditingController(text: ronda.nombre,),
        decoration: InputDecoration(
          labelText: 'Nombre ronda',
          hintText: 'escribe el nombre de la ronda aqui',
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

  Widget _entregaInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: TextEditingController(text: ronda.entrega,),
        decoration: InputDecoration(
          labelText: 'Entrega',
          hintText: 'Lugar de Entrega(Solo en presencial)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Entrega vacio';
          }
          setState(()  {
            _entrega = value;
          });
          return null;
        },
      ),
    );
  }

  Widget _dineroInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: TextEditingController(text: ronda.dinero.toString(),),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        decoration: InputDecoration(
          labelText: 'Dinero maximo',
          hintText: '000',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'dinero vacio';
          }
          setState(()  {
            _dinero = value;
          });
          return null;
        },
      ),
    );
  }

  Widget _fechaInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: InputDatePickerFormField(
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 100),
        fieldHintText: 'Fecha maxima entrega',
        fieldLabelText: '${_fechaMaxima}',
        errorFormatText: 'Formato incorrecto',
        errorInvalidText: 'Fecha incorrecta',
        onDateSubmitted: (date) {
          setState(() {
            _fechaMaxima = date;
          });
        },
        onDateSaved: (date) {
          setState(() {
            _fechaMaxima = date;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Ronda'),
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
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _nombreInput(),
                _dineroInput(),
                _entregaInput(),
                Text(overflow: TextOverflow.ellipsis, 'Fecha entrega maxima',style: TextStyle(color: Colors.blue.shade400, fontSize: 10.0,)),
                _fechaInput(),
                _botonesConf(context),
                _botonAccion(context),
              ],
            ),
          )
      ),
    );
  }

  Widget _botonesConf(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Modificar Ronda', style: TextStyle(
                color: Colors.blue, fontSize: 15.0,)),
              onPressed: () async{
                if(_formKey.currentState!.validate()){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                  );
                  String mensaje = await modificarRonda(ronda);
                  if(mensaje == "OK"){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ronda modificada correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaScreen(usuario,ronda.id,ronda.nombre)));
                  } else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error, rondae incorrecta', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                  );
                }
              }
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Eliminar ronda', style: TextStyle(
                color: Colors.blue, fontSize: 15.0,)),
              onPressed: () async{
                if(_formKey.currentState!.validate()){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                  );
                  String mensaje = await eliminarRonda(ronda);
                  if(mensaje == "OK"){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('participante eliminado correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> UsuRondasScreen(usuario)));
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

  Widget _botonAccion(context){
    if(ronda.estado == "Empezando"){
      return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('Realizar sorteo', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: () async{
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
            );
            String mensaje = await sorteo(ronda.id );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.yellow),
            );
            Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaScreen(usuario,ronda.id,ronda.nombre)));
          }
      );
    } else {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('Finalizar ronda', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: () async{
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
            );
            String mensaje = await finalizar(ronda.id );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.yellow),
            );
            usuario.rondas.removeWhere((rond) => rond.id == ronda.id);
            Navigator.push(context, MaterialPageRoute(builder: (context)=> UsuRondasScreen(usuario)));
          }
      );
    }
  }

  Future<String> modificarRonda(Ronda ronda) async {
    final response = await http.post(
      Uri.parse('?action=postRonda'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, Ronda>{
        'ronda': ronda,
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

  Future<String> eliminarRonda(Ronda ronda) async {
    final response = await http.post(
      Uri.parse('?action=deleteRonda&idronda='+ronda.id),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, Ronda>{
        'ronda': ronda,
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

  Future<String> sorteo(idRonda) async {
    final response = await http.get(Uri.parse('?action=sorteo&idronda='+idRonda));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return json["mensaje"];
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

  Future<String> finalizar(idRonda) async {
    final response = await http.get(Uri.parse('?action=finalizar&idronda='+idRonda));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return json["mensaje"];
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

}