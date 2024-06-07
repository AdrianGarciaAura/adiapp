import 'package:adiapp/model/datos_usuario.dart';
import 'package:adiapp/screen/crear_usuario.dart';
import 'package:adiapp/screen/usuario_rondas.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String _link = 'https://script.google.com/macros/s/AKfycbxNgjyhiPFrCClFNNpJGCtplx47T9VWtvo2Bh3KTKBKCY_z0_-uiUMb774PGauAPztzwA/exec';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _user = "";
  String _password = "";
  final _formKey = GlobalKey<FormState>();

  Widget _eMailInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Mail',
          hintText: 'nombre@mail.com',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'El mail no puede estar vacio.';
          }
          setState(()  {
            _user = value.trim();
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
        decoration: InputDecoration(
          labelText: 'Escribe tu contraseña',
          hintText: 'Password',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Sorry, password can not be empty.';
          }
          if(value.length < 8){
            return 'Sorry, password length must be 8 characters or greater.';
          }
          setState(()  {
          _password = value.trim();
          });
          return null;
        },
      ),
    );
  }

  Widget _loginButton(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: () async{//empieza funcion
            if(_formKey.currentState!.validate()){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );
              DatosUsuario datos = await login(_user,_password);
              if(datos.mensaje == "ok"){
                Navigator.push(context,MaterialPageRoute(builder: (context) => UsuRondasScreen(datos.dato)));
              } else{
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(datos.mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error, login incorrecto', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
              );
            }

          }//acaba funcion
      ),
    );
  }

  Widget _createrUserButton(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          child: const Text('Crear usuario', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> CreaterUserScreen()));
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade400,
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontSize: 24),
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
                    _eMailInput(),
                    _passwordInput(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: _createrUserButton(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: _loginButton(),
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

  Future<DatosUsuario> login(mail,password) async {
    final response = await http
        .get(Uri.parse(_link+'?action=login&mail='+mail+'&password=Z'+password));
    if (response.statusCode == 200) {
      return DatosUsuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

}