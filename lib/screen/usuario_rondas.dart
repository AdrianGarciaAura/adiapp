import 'package:flutter/material.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/model/ronda.dart';
import 'crear_ronda.dart';
import 'datos_ronda.dart';
import 'datos_usuario.dart';

//pantalla rondas de un usuario
class UsuRondasScreen extends StatelessWidget {
  Usuario usuario;
  UsuRondasScreen(this.usuario,{Key? key}) : super(key: key);

  //se construye los widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar con boton configuracion usuario y añadir ronda
        appBar: AppBar(
          title: Text('Rondas ' + usuario.nombre),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue.shade400,
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontSize: 24),
          actions: [
            IconButton(
              onPressed: () {
                //se va a configuracion usuario
                Navigator.push(context, MaterialPageRoute(builder: (context)=> UserScreen(usuario)));
              },
              icon: Icon(Icons.settings,color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                //se va a creacion ronda
                Navigator.push(context, MaterialPageRoute(builder: (context)=> CreaterRondaScreen(usuario)));
              },
              icon: Icon(Icons.add_circle,color: Colors.white),
            ),
          ],
        ),
        body: _RondasListView(usuario)


    );
  }
}

//lista de rondas
class _RondasListView extends StatelessWidget {
  Usuario usuario;
  _RondasListView(this.usuario);

  @override
  Widget build(BuildContext context) {
    List<Ronda> _data = usuario.rondas;
    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (context,index)=>
          _listItem(context,_data[index]),
    );
  }
  //elemento de la lista de rondas
  Widget _listItem(BuildContext context, Ronda element){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        tileColor: Colors.white,
        onTap: () => Navigator.push(context, MaterialPageRoute( builder: (context) => RondaScreen(usuario,element.id,element.nombre))),
        trailing:  Text('${element.num} Part', style: TextStyle(color: Colors.blue.shade400, fontSize: 20.0,),),
        title: Text('${element.tipo}: ${element.nombre}', style: TextStyle(color: Colors.teal, fontSize: 15.0,),),
        subtitle: Text('gestionador: ${element.gestionador}, estado: ${element.estado}', style: TextStyle(color: Colors.blue.shade400, fontSize: 10.0,),),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(20.0)
        ),
      ),
    );
  }
}