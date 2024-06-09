import 'dart:ffi';
import 'package:adiapp/model/participante.dart';
import 'package:adiapp/screen/usuario_rondas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/model/ronda.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String _link = 'https://script.google.com/macros/s/AKfycbxXxRI_y1l6lPxXHfBURrQJbVE3pVbV81JgYwRFd8R8cprgfjAQlOM0Tj9n52Fuoe8k/exec';

class CreaterRondaScreen extends StatefulWidget {
  Usuario usuario;
  CreaterRondaScreen(this.usuario,{Key? key}) : super(key: key);

  @override
  State<CreaterRondaScreen> createState() => _CreaterRondaScreenState(usuario);
}

class _CreaterRondaScreenState extends State<CreaterRondaScreen> {
  Usuario usuario;
  String _nombre = "";
  String _tipo = "";
  String _fechaMaxima = "";
  String _entrega = "";
  String _dinero = "";
  List<String> listaTipo = <String>["ADistancia","Presencial"];

  final _formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  _CreaterRondaScreenState(this.usuario);

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
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Tipo vacio';
          }
          setState(()  {
            _tipo = value;
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
                  _tipo,"",_entrega,_fechaMaxima.toString(),int.parse(_dinero),'Empezando',participantes);
              String? mensaje = await crearRonda(ronda);
              if(mensaje != null){
                if(mensaje.substring(0,2) == "OK"){
                  ronda.id = mensaje.substring(2);
                  usuario.rondas.add(ronda);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ronda creada correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                  );
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> UsuRondasScreen(usuario)));
                } else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(mensaje, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                  );
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error, ronda incorrecto', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
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
        ],
      )

    );
  }

  Future<String?> crearRonda(Ronda ronda) async {
    final response = await http.post(
      Uri.parse(_link+'?action=postRonda'),
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

}