
import 'package:adiapp/screen/usuario_rondas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/model/ronda.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/datos_ronda.dart';
import '../model/participante.dart';
import 'datos_amigo.dart';
import 'ronda_part.dart';

const String _link = 'https://script.google.com/macros/s/AKfycbxNgjyhiPFrCClFNNpJGCtplx47T9VWtvo2Bh3KTKBKCY_z0_-uiUMb774PGauAPztzwA/exec';


class RondaScreen extends StatefulWidget {
  Usuario usuario;
  String idRonda;
  String nombreRonda;
  RondaScreen(this.usuario,this.idRonda,this.nombreRonda,{Key? key}) : super(key: key);

  @override
  State<RondaScreen> createState() => _RondaScreenState(usuario,idRonda,nombreRonda);
}

class _RondaScreenState extends State<RondaScreen>  {
  Usuario usuario;
  String idRonda;
  String nombreRonda;
  String _nombre = "";
  String _entrega = "";
  String _dinero = "";
  String _fechaMaxima = "";
  final _formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  _RondaScreenState(this.usuario,this.idRonda,this.nombreRonda);

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
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> UsuRondasScreen(usuario)));
            },
            icon: Icon(Icons.arrow_back,color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<DatosRonda>(
        future: getRonda(idRonda),
        builder: (context, snapshot){
          if(snapshot.hasData){
            print("hay datos");
            Ronda ronda = snapshot.data!.dato;
            return _Contenido(ronda);
          }else{
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<DatosRonda> getRonda(idRonda) async {
    print("antes de la llamada api");
    final response = await http
        .get(Uri.parse(_link+'?action=getRonda&idronda='+idRonda));
    print("despues de la llamada api");
    if (response.statusCode == 200) {
      print("todo bien en la llamada");
      return DatosRonda.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

  Widget _nombreInput(ronda){
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

  Widget _entregaInput(ronda){
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

  Widget _dineroInput(ronda){
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

  Widget _fechaInput(ronda){
    return Container(
        margin: EdgeInsets.only(bottom: 16.0),
        child: TextFormField(
          controller: dateController, //editing controller of this TextField
          decoration: const InputDecoration(

              icon: Icon(Icons.calendar_today), //icon of text field
              labelText: "Fecha maxima de entrega" //label text of field
          ),
          readOnly: true,  // when true user cannot edit text
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(), //get today's date
                firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                lastDate: DateTime(2101)
            );

            if(pickedDate != null ){
              print(pickedDate);  //get the picked date in the format => 2022-07-04 00:00:00.000
              String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
              print(formattedDate); //formatted date output using intl package =>  2022-07-04
              //You can format date as per your need

              setState(() {
                dateController.text = formattedDate; //set foratted date to TextField value.
              });
            }else{
              print("Fecha no seleccionada");
            }
          },
          validator: (value){
            if(value == null || value.isEmpty){
              return 'sin fecha';
            }
            setState(()  {
              _fechaMaxima = value;
            });
            return null;
          },
        )
    );
  }

  @override
  Widget _Contenido(Ronda ronda) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(overflow: TextOverflow.ellipsis, 'ID ${ronda.id}: ${ronda.nombre}',style: TextStyle(color: Colors.teal, fontSize: 20.0,)),
            Text(overflow: TextOverflow.ellipsis, 'Gestionador: ${ronda.gestionador}: ${ronda.mail}',style: TextStyle(color: Colors.blue.shade400, fontSize: 20.0,)),
            Text(overflow: TextOverflow.ellipsis, '${ronda.tipo}: ${(ronda.tipo == 'ADistancia') ? 'finaliza el '+ ronda.fechaMaxima.substring(0,10) : ronda.entrega}',style: TextStyle(color: Colors.blue.shade400, fontSize: 20.0,)),
            Text(overflow: TextOverflow.ellipsis, 'Num.Part: ${ronda.num}, Estado: ${ronda.estado}',style: TextStyle(color: Colors.blue.shade400, fontSize: 20.0,)),
            Text(overflow: TextOverflow.ellipsis, 'dinero: ${ronda.dinero}€',style: TextStyle(color: Colors.blue.shade400, fontSize: 20.0,)),
            _botonesParticipantes(context,ronda),
            _Config(context,ronda)
          ],
        ),
        
      ],
    );
  }

  Widget _botonesParticipantes(context,ronda){
    if(ronda.estado == "SorteoRealizado"){
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Datos Amigo', style: TextStyle(
                  color: Colors.white, fontSize: 15.0,)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> AmigoScreen(usuario,ronda)));
                }
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Participantes', style: TextStyle(
                  color: Colors.white, fontSize: 15.0,)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaParticipanteScreen(usuario,ronda)));
                }
            ),
          ),
        ],
      );
    } else {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Participantes', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaParticipanteScreen(usuario,ronda)));
          }
      );
    }
  }

  Widget _Config(context,ronda) {
    if(ronda.mail == usuario.mail){
      return Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(overflow: TextOverflow.ellipsis, 'Aqui puedes modificar datos:',style: TextStyle(color: Colors.teal, fontSize: 20.0,)),
                _nombreInput(ronda),
                _entregaInput(ronda),
                _fechaInput(ronda),
                _dineroInput(ronda),
                _botonesConf(context,ronda),
                _botonAccion(context,ronda),
              ],
            ),
          )
      );
    } else {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('Bloqueado', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: null
      );
    }
  }
  
  Widget _botonesConf(context,Ronda ronda) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Modificar Ronda', style: TextStyle(
                  color: Colors.white, fontSize: 15.0,)),
                onPressed: () async{
                  if(_formKey.currentState!.validate()){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                    );
                    ronda.nombre = _nombre;
                    ronda.entrega = _entrega;
                    ronda.dinero = int.parse(_dinero);
                    ronda.fechaMaxima = _fechaMaxima;
                    List<Participante> parts = ronda.participantes;
                    ronda.participantes = [];
                    String? mensaje = await modificarRonda(ronda);
                    if(mensaje == "OK"){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ronda modificada correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                      );
                      usuario.rondas.removeWhere((rond) => rond.id == ronda.id);
                      usuario.rondas.add(ronda);
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaScreen(usuario,ronda.id,ronda.nombre)));
                    } else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(mensaje!, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                      );
                    }
                    ronda.participantes = parts;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error, ronda incorrecta', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                    );
                  }
                }
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Eliminar ronda', style: TextStyle(
                  color: Colors.white, fontSize: 15.0,)),
                  onPressed: () async{
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                    );
                    List<Participante> parts = ronda.participantes;
                    ronda.participantes = [];
                    String? mensaje = await eliminarRonda(ronda);
                    if(mensaje == "OK"){
                      usuario.rondas.removeWhere((rond) => rond.id == ronda.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ronda eliminado correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> UsuRondasScreen(usuario)));
                    } else{
                      ronda.participantes = parts;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(mensaje!, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                      );
                    }
                  }
            ),
          ),
        ],
      );
  }

  Widget _botonAccion(context,ronda){
      if(ronda.estado == "Empezando"){
        return ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Realizar sorteo', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
            onPressed: () async{
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );
              String mensaje = await sorteo(ronda.id );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );
              Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaScreen(usuario,ronda.id,ronda.nombre)));
            }
        );
      } else {
        return ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Finalizar ronda', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
            onPressed: () async{
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );
              String mensaje = await finalizar(ronda.id );
              if(mensaje == 'OK'){
                usuario.rondas.removeWhere((rond) => rond.id == ronda.id);
                Navigator.push(context, MaterialPageRoute(builder: (context)=> UsuRondasScreen(usuario)));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );

            }
        );
      }
  }

  Future<String?> modificarRonda(Ronda ronda) async {
    final response = await http.post(
      Uri.parse(_link+'?action=putRonda'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'ronda': ronda},
          toEncodable: (Object? value) => value is Ronda
              ? Ronda.toJson(value)
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

  Future<String?> eliminarRonda(Ronda ronda) async {
    final response = await http.post(
      Uri.parse(_link+'?action=deleteRonda&idronda='+ronda.id),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'ronda': ronda},
          toEncodable: (Object? value) => value is Ronda
              ? Ronda.toJson(value)
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

  Future<String> sorteo(idRonda) async {
    final response = await http.get(Uri.parse(_link+'?action=sorteo&idronda='+idRonda));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return json["mensaje"];
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

  Future<String> finalizar(idRonda) async {
    final response = await http.get(Uri.parse(_link+'?action=finalizar&idronda='+idRonda));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return json["mensaje"];
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

}