import 'package:flutter/material.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/model/ronda.dart';
import '../model/participante.dart';
import 'anyadir_participante.dart';
import 'datos_ronda.dart';

//pantalla participantes ronda
class RondaParticipanteScreen extends StatefulWidget {
  Usuario usuario;
  Ronda ronda;
  RondaParticipanteScreen(this.usuario,this.ronda,{Key? key}) : super(key: key);

  @override
  State<RondaParticipanteScreen> createState() => _RondaParticipanteScreenState(usuario,ronda);
}

class _RondaParticipanteScreenState extends State<RondaParticipanteScreen> {
  Usuario usuario;
  Ronda ronda;
  _RondaParticipanteScreenState(this.usuario, this.ronda);

  //construcion widgets
  @override
  Widget build(BuildContext context) {
    List<Participante> _data = ronda.participantes;
    return Scaffold(
      //app bar con boton para añadir o eliminar participantes y volver
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
                //sevuelve a datos ronda
                Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaScreen(usuario,ronda.id,ronda.nombre)));
              },
              icon: Icon(Icons.arrow_back,color: Colors.white),
            ),
            _botonModificar(context)
          ],
        ),
        //lista participantes
        body: ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, index) => _listItem(context, _data[index]),
            ),
    );
  }

  //metodo para ver si se puede añadir participantes y enseñar e boton
  Widget _botonModificar(context){
    if(ronda.mail == usuario.mail){
      return IconButton(
        onPressed: () {
          //se va a la pantalla de añadir participante
          Navigator.push(context, MaterialPageRoute(builder: (context)=> ParticipanteScreen(usuario,ronda)));
        },
        icon: Icon(Icons.add,color: Colors.white),
      );
    } else {
      return IconButton(
        onPressed: null,
        icon: Icon(Icons.add,color: Colors.blue.shade400),
      );
    }
  }

  //elemento de la lista de participante
  Widget _listItem(BuildContext context, Participante element) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        tileColor: Colors.white,
        title: Text('${element.nombre}', style: TextStyle(
          color: Colors.teal, fontSize: 15.0,),),
        subtitle: Text('estado A.D.I: ${element.adi}', style: TextStyle(
          color: Colors.blue.shade400, fontSize: 10.0,),),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(20.0)
        ),
      ),
    );
  }
}