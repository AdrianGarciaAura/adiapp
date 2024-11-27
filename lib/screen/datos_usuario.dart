import 'dart:ffi';

import 'package:adiapp/screen/usuario_rondas.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/screen/login.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

import '../model/ronda.dart';

const String _link = 'https://script.google.com/macros/s/AKfycbw0QgK5Ijo619D_4lFOM0o7I9_2xJqeYfjs53P6NM8soTSwcOEHYtVVQjigejqUMdawrQ/exec';

//pantalla configuracion usuario
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
  final _formKey = GlobalKey<FormState>();
  InterstitialAd? _interstitialAd;
  final String _adUnitId = Platform.isAndroid ? 'ca-app-pub-3940256099942544/1033173712' : 'ca-app-pub-3940256099942544/4411468910';

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
    _loadAd();
  }

  _UserScreenState(this.usuario);

  //widget para modificar nombre
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

  //widget para modificar fecha nacimiento
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

  //widget para modificar contraseña
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

  //boton de modificar usuario
  Widget _CambioButton(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          child: const Text('Aplicar cambios', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          //metodo modificar usuario
          onPressed: () async{
            if(_formKey.currentState!.validate()){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conectando... espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );
              usuario.nombre = _nombre;
              usuario.fecha = _fecha;
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
              //reflejar los datos en la app
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

  //boton eliminar usuario
  Widget _DeleteButton(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          child: const Text('Borrar Usuario', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          //metodo eliminar usuario
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
                //se vuelve al login
                Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
              } else{
                //reflejar los datos en la app
                usuario.rondas = ronds;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(mensaje!, style: TextStyle(color: Colors.white,)),backgroundColor: Colors.red),
                );
              }
          }
      ),
    );
  }

  //se construye los widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar con boton de regreso
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
              _interstitialAd?.show();
              //se vuelve a la lista de rondas
              Navigator.push(context, MaterialPageRoute(builder: (context)=> UsuRondasScreen(usuario)));
            },
            icon: Icon(Icons.arrow_back,color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              ListView(
                padding: const EdgeInsets.all(8),
                children: <Widget>[
                  //formulario de modificar usuario
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _nombreInput(),
                          _fechaInput(),
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

  /// Loads an interstitial ad.
  void _loadAd() async {

    InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (InterstitialAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            // ignore: avoid_print
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  //llamada a la api de modificar usuario
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

    //recibir respuesta
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return json["mensaje"];
    } else if (response.statusCode == 302) {
      if (response.headers.containsKey("location")) {
        //recibir respuesta desde la redirecion
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

  //llamada a la api de modificar usuario
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