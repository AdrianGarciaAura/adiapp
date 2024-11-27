import 'package:flutter/material.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/model/ronda.dart';
import 'package:adiapp/screen/login.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';

const String _link = 'https://script.google.com/macros/s/AKfycbw0QgK5Ijo619D_4lFOM0o7I9_2xJqeYfjs53P6NM8soTSwcOEHYtVVQjigejqUMdawrQ/exec';

//pantalla crear usuario
class CreaterUserScreen extends StatefulWidget {
  const CreaterUserScreen({Key? key}) : super(key: key);

  @override
  State<CreaterUserScreen> createState() => _CreaterUserScreenState();
}

class _CreaterUserScreenState extends State<CreaterUserScreen> {
  String _mail = "";
  String _nombre = "";
  String _password = "";
  String _fecha = "";
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
  }


  //widget para meter el mail
  Widget _eMailInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Mail',
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
            _mail = value.trim();
          });
          return null;
        },
      ),
    );
  }

  //widget para meter el nombre
  Widget _nombreInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Nombre usuario',
          hintText: 'escribe tu nombre aqui',
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

  //widget para meter la fecha de nacimiento
  Widget _fechaInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Fecha nacimiento',
          hintText: '00-00-0000',
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

  //widget para meter la contraseña
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
            return 'Contraseña vacia';
          }
          if(value.length < 8){
            return 'La contraseña debe tener 8 o mas caracteres';
          }
          setState(()  {
            _password = value;
          });
          return null;
        },
      ),
    );
  }

  //boton para crear el usuario
  Widget _creatingButton(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          child: const Text('Registrar', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          //metodo para crear el usuario
          onPressed: () async{
            if(_formKey.currentState!.validate()){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );
              List<Ronda> rondas = [];
              Usuario usuario = Usuario(_mail,_nombre,
                  "Z"+_password,"no",_fecha,"anulado","",rondas);
              String? mensaje = await crearUsuario(usuario);
              if(mensaje == "OK"){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('usuario creado correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                );
                //se vuelve al login
                Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
              } else{
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(mensaje!, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
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

  //boton de volver
  Widget _volverButton(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          child: const Text('volver', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: () {
            //se vuelve al login
            Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
          }
      ),
    );
  }

  //se construye los widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar
      appBar: AppBar(title: const Text('Registro'),
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
          //el formulario para crear el usuario
          Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _eMailInput(),
                    _nombreInput(),
                    _fechaInput(),
                    _passwordInput(),
                    Text(overflow: TextOverflow.ellipsis, "-Consentimiento: Al crear un usuario en",style: TextStyle(color: Colors.teal, fontSize: 14.0,)),
                    Text(overflow: TextOverflow.ellipsis, "A.D.I Amigo distante invisible aceptas que:",style: TextStyle(color: Colors.teal, fontSize: 14.0,)),
                    Text(overflow: TextOverflow.ellipsis, "-Darnos los datos necesarios para el correcto funcionamiento de la app,",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "como el mail para poderte mandar los mails necesarios para las rondas",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "del amigo invisible o la dirección para que otros usuarios la fecha de",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "puedan mandarte el regalo. También se pide",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "nacimiento para futuras funcionalidades.",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "-Los datos se recogen en una base de datos segura en un servidor",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "de pago donde solo tiene acceso el autor de la aplicación.",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "-Política de privacidad:",style: TextStyle(color: Colors.teal, fontSize: 14.0,)),
                    Text(overflow: TextOverflow.ellipsis, "el autor se compromete a no usar o filtrar los datos aparte",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "de los necesarios para el correcto funcionamiento de la app.",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "-Términos de servicio:",style: TextStyle(color: Colors.teal, fontSize: 14.0,)),
                    Text(overflow: TextOverflow.ellipsis, "-Uso de anuncios: Los anuncios se usarán para mantener",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "la aplicación activa y se usara el sdk admob.",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "-Tipos de anuncios: Los anuncios serán banners y anuncios intersticiales",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "-Conducta del usuario: Los usuarios deben respetar los datos",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "proporcionados para realizar el amigo invisible y no hacer un mal",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "uso del sistema. Si algún usuario hace mal uso de los datos",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "que se le proporciona o de la misma aplicación, sera directamente",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "baneado de la aplicación y si las consecuencias son muy graves,",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    Text(overflow: TextOverflow.ellipsis, "denunciado ante la ley.",style: TextStyle(color: Colors.teal, fontSize: 10.0,)),
                    _creatingButton(),
                    _volverButton()
                  ],
                ),
              )
          ),
        ],
      )

    );
  }



  //llamada a la api para crear el usuario
  Future<String?> crearUsuario(Usuario usuario) async {
    final response = await http.post(
      Uri.parse(_link+'?action=postUsuario'),
      headers: {'Content-type': 'application/json',
        'Accept': 'application/json'},
      body: jsonEncode({'usuario': usuario},
          toEncodable: (Object? value) => value is Usuario
              ? Usuario.toJson(value)
              : throw UnsupportedError('Cannot convert to JSON: $value')),
    );

    //recibir respuesta
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return json["mensaje"];
    } else if (response.statusCode == 302) {
      //recibir respuesta desde la redirecion
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
      throw Exception('Fallo al acceder a la api '+response.statusCode.toString());
    }
  }

}