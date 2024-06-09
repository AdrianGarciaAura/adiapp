import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/model/ronda.dart';
import 'package:http/http.dart' as http;
import '../model/partCompleto.dart';
import '../model/participante.dart';
import 'datos_ronda.dart';
import 'ronda_part.dart';

const String _link = 'https://script.google.com/macros/s/AKfycbxXxRI_y1l6lPxXHfBURrQJbVE3pVbV81JgYwRFd8R8cprgfjAQlOM0Tj9n52Fuoe8k/exec';

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
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaParticipanteScreen(usuario,ronda)));
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
                      _eMailInput(),
                      Text(overflow: TextOverflow.ellipsis, 'Pon datos particicipantes para:',style: TextStyle(color: Colors.blue.shade400, fontSize: 20.0,)),
                      _botones(context),
                    ],
                  ),
                )
            ),
          ],
        )
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
                child: const Text('Añadir', style: TextStyle(
                  color: Colors.blue, fontSize: 15.0,)),
                onPressed: () async{
                  if(_formKey.currentState!.validate()){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                    );
                    ParticipanteCompl part = ParticipanteCompl(_nombre,_mail,'','','','nulo','no seleccionado');
                    String? mensaje = await anyadirParticipante(part, ronda.id);
                    if(mensaje == "OK"){
                      ronda.participantes.add(Participante(part.nombre, part.mail, part.adi));
                      ronda.num = ronda.num+1;
                      usuario.rondas.removeWhere((rond) => rond.id == ronda.id);
                      usuario.rondas.add(ronda);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('participante añadido correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaParticipanteScreen(usuario,ronda)));
                    } else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(mensaje!, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
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
                child: const Text('Eliminar', style: TextStyle(
                  color: Colors.blue, fontSize: 15.0,)),
                onPressed: () async{
                  if(_formKey.currentState!.validate()){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                    );
                    ParticipanteCompl part = ParticipanteCompl(_nombre,_mail,'','','','nulo','no seleccionado');
                    String? mensaje = await deleteParticipante(part, ronda.id);
                    if(mensaje == "OK"){
                      ronda.participantes.removeWhere((parti) => parti.mail == part.mail);
                      ronda.num = ronda.num-1;
                      usuario.rondas.removeWhere((rond) => rond.id == ronda.id);
                      usuario.rondas.add(ronda);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('participante eliminado correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaParticipanteScreen(usuario,ronda)));
                    } else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(mensaje!, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
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
            _mail = value.trim();
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
            _nombre = value.trim();
          });
          return null;
        },
      ),
    );
  }

  Future<String?> anyadirParticipante(ParticipanteCompl participante,String idRonda) async {
    final response = await http.post(
      Uri.parse(_link+'?action=postParticipante&idronda='+idRonda),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'participante': participante},
          toEncodable: (Object? value) => value is ParticipanteCompl
              ? ParticipanteCompl.toJson(value)
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
      throw Exception('Fallo al acceder a la api' + response.statusCode.toString());
    }
  }

  Future<String?> deleteParticipante(ParticipanteCompl participante,String idRonda) async {
    final response = await http.post(
      Uri.parse(_link+'?action=deleteParticipante&idronda='+idRonda),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'participante': participante},
          toEncodable: (Object? value) => value is ParticipanteCompl
              ? ParticipanteCompl.toJson(value)
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