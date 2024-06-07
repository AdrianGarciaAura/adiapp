import 'dart:ffi';

import 'package:adiapp/screen/usuario_rondas.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/screen/login.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/ronda.dart';

const String _link = 'https://script.google.com/macros/s/AKfycbxNgjyhiPFrCClFNNpJGCtplx47T9VWtvo2Bh3KTKBKCY_z0_-uiUMb774PGauAPztzwA/exec';

class UserScreen extends StatefulWidget {
  Usuario usuario;
  UserScreen(this.usuario,{Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState(usuario);
}

class _UserScreenState extends State<UserScreen> {
  Usuario usuario;
  String _nombre = "";
  String _password = "";
  String _fecha = "";
  String _direccion = "";
  final _formKey = GlobalKey<FormState>();

  _UserScreenState(this.usuario);

  Widget _nombreInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: TextEditingController(text: usuario.nombre,),
        decoration: InputDecoration(
          labelText: 'Nombre usuario',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Nombre vacio';
          }
          setState(()  {
            _nombre = value.trim();
          });
          return null;
        },
      ),
    );
  }

  Widget _fechaInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: TextEditingController(text: usuario.fecha,),
        decoration: InputDecoration(
          labelText: 'Fecha nacimiento',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Fecha vacia';
          }
          if(value.indexOf('-') != 2 || value.indexOf('-',3) != 5){
            return 'Fecha incorrecta';

          }
          setState(()  {
            _fecha = value;
          });
          return null;
        },
      ),
    );
  }

  Widget _direccionInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: TextEditingController(text: usuario.direccion,),
        decoration: InputDecoration(
          labelText: 'Direccion',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Direccion vacio';
          }
          setState(()  {
            _direccion = value;
          });
          return null;
        },
      ),
    );
  }

  Widget _passwordInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        obscureText: true,
        obscuringCharacter: '*',
        controller: TextEditingController(text: usuario.password.substring(1),),
        decoration: InputDecoration(
          labelText: 'Nueva contraseña',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Contraseña vacia';
          }
          if(value.length < 8){
            return 'La contraseña debe tener 8 o mas caracteres';
          }
          setState(()  {
            _password = value.trim();
          });
          return null;
        },
      ),
    );
  }

  Widget _CambioButton(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          child: const Text('Aplicar cambios', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: () async{
            if(_formKey.currentState!.validate()){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );
              usuario.nombre = _nombre;
              usuario.fecha = _fecha;
              usuario.direccion = _direccion;
              usuario.password ="Z"+_password;
              List<Ronda> ronds = usuario.rondas;
              usuario.rondas = [];
              String? mensaje = await modificarUsuario(usuario);
              if(mensaje == "OK"){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('usuario modificado correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                );
              } else{
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(mensaje!, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                );
              }
              usuario.rondas = ronds;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error, usuario incorrecto', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
              );
            }
          }
      ),
    );
  }

  Widget _DeleteButton(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          child: const Text('Borrar Usuario', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: () async{
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );
              List<Ronda> ronds = usuario.rondas;
              usuario.rondas = [];
              String? mensaje = await borrarUsuario(usuario);
              if(mensaje == "OK"){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('usuario borrado correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                );
                Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
              } else{
                usuario.rondas = ronds;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(mensaje!, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                );
              }
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade400,
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontSize: 24),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> UsuRondasScreen(usuario)));
            },
            icon: Icon(Icons.arrow_back,color: Colors.white),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _nombreInput(),
                    _fechaInput(),
                    _direccionInput(),
                    _passwordInput(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: _CambioButton()
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                            child: _DeleteButton()
                        ),
                      ],
                    )
                  ],
                ),
              )
          ),
        ],
      )
    );
  }

  Future<String?> modificarUsuario(Usuario usuario) async {
    final response = await http.post(
      Uri.parse(_link+'?action=putUsuario'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'usuario': usuario},
          toEncodable: (Object? value) => value is Usuario
              ? Usuario.toJson(value)
              : throw UnsupportedError('Cannot convert to JSON: $value')),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return json["mensaje"];
    } else if (response.statusCode == 302) {
      if (response.headers.containsKey("location")) {
        String? url = response.headers["location"];
        final getResponse = await http.get(Uri.parse((url == null) ? "" : url));
        if (getResponse.statusCode == 200) {
          Map<String, dynamic> json = jsonDecode(getResponse.body);
          return json["mensaje"];
        } else {
          throw Exception(
              'Fallo al acceder a la api' + getResponse.statusCode.toString());
        }
      }
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Fallo al acceder a la api'+response.statusCode.toString());
    }
  }

  Future<String?> borrarUsuario(Usuario usuario) async {
    final response = await http.post(
      Uri.parse(_link+'?action=deleteUsuario&mail='+usuario.mail),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'usuario': usuario},
          toEncodable: (Object? value) => value is Usuario
              ? Usuario.toJson(value)
              : throw UnsupportedError('Cannot convert to JSON: $value')),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return json["mensaje"];
    } else if (response.statusCode == 302) {
      if (response.headers.containsKey("location")) {
        String? url = response.headers["location"];
        final getResponse = await http.get(Uri.parse((url == null) ? "" : url));
        if (getResponse.statusCode == 200) {
          Map<String, dynamic> json = jsonDecode(getResponse.body);
          return json["mensaje"];
        } else {
          throw Exception(
              'Fallo al acceder a la api' + getResponse.statusCode.toString());
        }
      }
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Fallo al acceder a la api'+response.statusCode.toString());
    }
  }

}