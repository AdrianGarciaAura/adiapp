import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/model/ronda.dart';
import 'package:http/http.dart' as http;
import '../model/partCompleto.dart';
import '../model/participante.dart';
import 'ronda_part.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

const String _link = 'https://script.google.com/macros/s/AKfycbw0QgK5Ijo619D_4lFOM0o7I9_2xJqeYfjs53P6NM8soTSwcOEHYtVVQjigejqUMdawrQ/exec';

//pantalla para añadir o quitar participantes
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
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAdB();
  }

  Future<void> _loadAdB() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
    await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      // TODO: replace these test ad units with your own ad unit.
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716',
      size: size,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  @override
  void initState() {
    super.initState();
  }

  _ParticipanteScreenState(this.usuario, this.ronda);

  //constructor de los widget
  @override
  Widget build(BuildContext context) {
    List<Participante> _data = ronda.participantes;
    return Scaffold(
      //app bar con un boton para volver
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
                  //se vuelve a la lista de participantes
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> RondaParticipanteScreen(usuario,ronda)));
                },
              icon: Icon(Icons.arrow_back,color: Colors.white),
            ),
          ],
        ),
        //el formulario para añadir o quitar participantes
        body: Center(
          child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: <Widget>[
                ListView(
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
                ),
                if (_anchoredAdaptiveAd != null && _isLoaded)
                  Container(
                    color: Colors.green,
                    width: _anchoredAdaptiveAd!.size.width.toDouble(),
                    height: _anchoredAdaptiveAd!.size.height.toDouble(),
                    child: AdWidget(ad: _anchoredAdaptiveAd!),
                  )
              ],
          ),
        ),
    );
  }

  //los botones para añadir o quitar el participante
  Widget _botones(context) {
    //en una fila
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Text('Añadir', style: TextStyle(
                  color: Colors.blue, fontSize: 15.0,)),
                //metodo añadir participante
                onPressed: () async{
                  if(_formKey.currentState!.validate()){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                    );
                    ParticipanteCompl part = ParticipanteCompl(_nombre,_mail,'','','','nulo','no seleccionado');
                    String? mensaje = await anyadirParticipante(part, ronda.id);
                    if(mensaje == "OK"){
                      //reflejar los datos en la app
                      ronda.participantes.add(Participante(part.nombre, part.mail, part.adi));
                      ronda.num = ronda.num+1;
                      usuario.rondas.removeWhere((rond) => rond.id == ronda.id);
                      usuario.rondas.add(ronda);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('participante añadido correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                      );
                      //se vuelve a la lista de participantes
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
                //metodo eliminar participante
                onPressed: () async{
                  if(_formKey.currentState!.validate()){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
                    );
                    ParticipanteCompl part = ParticipanteCompl(_nombre,_mail,'','','','nulo','no seleccionado');
                    String? mensaje = await deleteParticipante(part, ronda.id);
                    if(mensaje == "OK"){
                      //reflejar los datos en la app
                      ronda.participantes.removeWhere((parti) => parti.mail == part.mail);
                      ronda.num = ronda.num-1;
                      usuario.rondas.removeWhere((rond) => rond.id == ronda.id);
                      usuario.rondas.add(ronda);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('participante eliminado correctamente',style: TextStyle(color: Colors.white,)),backgroundColor: Colors.green),
                      );
                      //se vuelve a la lista de participantes
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

  //widget para añadir el mail
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

  //widget para añadir el nombre
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

  //llamada a la api para añadir participante
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
      throw Exception('Fallo al acceder a la api' + response.statusCode.toString());
    }
  }

  //llamada a la api para eliminar un participante
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

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
  }
}