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

class CreaterRondaScreen extends StatefulWidget {
  Usuario usuario;
  CreaterRondaScreen(this.usuario,{Key? key}) : super(key: key);

  @override
  State<CreaterRondaScreen> createState() => _CreaterRondaScreenState(usuario,DateTime.now());
}

class _CreaterRondaScreenState extends State<CreaterRondaScreen> {
  Usuario usuario;
  String _nombre = "";
  String _tipo = "";
  DateTime _fechaMaxima ;
  String _entrega = "";
  String _dinero = "";
  List<String> listaTipo = <String>["ADistancia","Presencial"];

  final _formKey = GlobalKey<FormState>();

  _CreaterRondaScreenState(this.usuario, this._fechaMaxima);

  Widget _nombreInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
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

  List<String> listaDeOpciones = <String>["A","B","C","D","E","F","G"];

  Widget _tipoInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField(
        items: listaTipo.map((e){
          return DropdownMenuItem(
            child: SizedBox(
              width: double.infinity,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            value: e,
          );
        }).toList(),
        onChanged: (value) {
          setState(()  {
            _tipo = value!;
          });
        },
        isDense: true,
        isExpanded: true,
      ),
    );
  }

  Widget _dineroInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
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

  Widget _creatingButton(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          child: const Text('Crear ronda', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: () async{
            if(_formKey.currentState!.validate()){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );
              List<Participante> participantes = [];
              Ronda ronda= Ronda('0',_nombre,usuario.nombre,usuario.mail,0,
                  _tipo,"",_entrega,_fechaMaxima.toString(),int.parse(_dinero),'Empezando',participantes);;
              String mensaje = await crearRonda(ronda);
              if(mensaje == "OK"){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ronda creada correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                );
                //Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
              } else{
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error, usuario incorrecto', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
              );
            }
          }
      ),
    );
  }

  Widget _volverButton(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          child: const Text('volver', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> UsuRondasScreen(usuario)));
          }
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
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _nombreInput(),
                _tipoInput(),
                _dineroInput(),
                _entregaInput(),
                Text(overflow: TextOverflow.ellipsis, 'Fecha entrega maxima',style: TextStyle(color: Colors.blue.shade400, fontSize: 10.0,)),
                _fechaInput(),
                _creatingButton(),
                _volverButton()
              ],
            ),
          )
      ),
    );
  }

  Future<String> crearRonda(Ronda ronda) async {
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

}