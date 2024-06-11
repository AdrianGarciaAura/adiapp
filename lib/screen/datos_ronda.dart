
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

const String _link = 'https://script.google.com/macros/s/AKfycbxXxRI_y1l6lPxXHfBURrQJbVE3pVbV81JgYwRFd8R8cprgfjAQlOM0Tj9n52Fuoe8k/exec';

//pantalla datos ronda
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

  //construcion widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar con boton para volver
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
              //se vuelve a las rondas del usuario
              Navigator.push(context, MaterialPageRoute(builder: (context)=> UsuRondasScreen(usuario)));
            },
            icon: Icon(Icons.arrow_back,color: Colors.white),
          ),
        ],
      ),
      //se construye los datos de la ronda a traves de la api
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

  //llamada a la api para recibir una ronda
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

  //widget para modificar el nombre
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

  //widget para modificar la entrega
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

  //widget para modificar el dinero
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

  //widget para modificar la fecha de entrega
  Widget _fechaInput(ronda){
    return Container(
        margin: EdgeInsets.only(bottom: 16.0),
        child: TextFormField(
          controller: dateController,
          decoration: const InputDecoration(

              icon: Icon(Icons.calendar_today),
              labelText: "Fecha maxima de entrega"
          ),
          readOnly: true,
          //accion cuando se pulsa el widget, que es para elegir la fecha
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101)
            );

            if(pickedDate != null ){
              print(pickedDate);
              String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
              print(formattedDate);

              setState(() {
                dateController.text = formattedDate;
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

  //se construye el widget con los datos de la ronda
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

  //botones de participantes, tambien esta el de amigo si se realizo el sorteo de la ronda
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
                  //se va la pantalla de amigo de la ronda
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
                  //se va a la pantalla con los participantes de la ronda
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
            //se va a la pantalla con los participantes de la ronda
            Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaParticipanteScreen(usuario,ronda)));
          }
      );
    }
  }

  //widget que solo se construye si el gestionador es el usuario conlas opciones para gestionar la ronda
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
      //si no eres el gestionador, te saldra bloqueado
      return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('Bloqueado', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: null
      );
    }
  }

  //botones eliminar y modificar en fila
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
                //metodo para modificar la ronda
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
                      //reflejar los datos en la app
                      usuario.rondas.removeWhere((rond) => rond.id == ronda.id);
                      usuario.rondas.add(ronda);
                      //se recarga la pantalla
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
                  //metodo para eliminar la ronda
                  onPressed: () async{
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                    );
                    List<Participante> parts = ronda.participantes;
                    ronda.participantes = [];
                    String? mensaje = await eliminarRonda(ronda);
                    if(mensaje == "OK"){
                      //reflejar los datos en la app
                      usuario.rondas.removeWhere((rond) => rond.id == ronda.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ronda eliminado correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                      );
                      //se vuelve a las rondas del usuario
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

  //boton de accion de ronda
  Widget _botonAccion(context,ronda){
      if(ronda.estado == "Empezando"){
        return ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Realizar sorteo', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
            //metodo para realizar el sorteo
            onPressed: () async{
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );
              String mensaje = await sorteo(ronda.id );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );
              //se recarga la pantalla
              Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaScreen(usuario,ronda.id,ronda.nombre)));
            }
        );
      } else {
        return ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Finalizar ronda', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
            //metodo para finalizar la ronda
            onPressed: () async{
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );
              String mensaje = await finalizar(ronda.id );
              if(mensaje == 'OK'){
                //reflejar los datos en la app
                usuario.rondas.removeWhere((rond) => rond.id == ronda.id);
                //se vuelve a las rondas del usuario
                Navigator.push(context, MaterialPageRoute(builder: (context)=> UsuRondasScreen(usuario)));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );

            }
        );
      }
  }

  //llamada a la api para modificar una ronda
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
      throw Exception('Fallo al acceder a la api'+response.statusCode.toString());
    }
  }

  //llamada a la api para eliminar una ronda
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
      throw Exception('Fallo al acceder a la api'+response.statusCode.toString());
    }
  }

  //llamada a la api para realizar el sorteo
  Future<String> sorteo(idRonda) async {
    final response = await http.get(Uri.parse(_link+'?action=sorteo&idronda='+idRonda));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return json["mensaje"];
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

  //llamada a la api para finalizar una ronda
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