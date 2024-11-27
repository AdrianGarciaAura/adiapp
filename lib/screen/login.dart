import 'package:adiapp/model/datos_usuario.dart';
import 'package:adiapp/screen/crear_usuario.dart';
import 'package:adiapp/screen/usuario_rondas.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'consent_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

const String _link = 'https://script.google.com/macros/s/AKfycbw0QgK5Ijo619D_4lFOM0o7I9_2xJqeYfjs53P6NM8soTSwcOEHYtVVQjigejqUMdawrQ/exec';

//pantalla login
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _user = "";
  String _password = "";
  var _isMobileAdsInitializeCalled = false;
  var _isPrivacyOptionsRequired = false;
  final _formKey = GlobalKey<FormState>();
  final _consentManager = ConsentManager();
  InterstitialAd? _interstitialAd;
  final String _adUnitId = Platform.isAndroid ? 'ca-app-pub-3940256099942544/1033173712' : 'ca-app-pub-3940256099942544/4411468910';


  @override
  void initState() {
    super.initState();

    _consentManager.gatherConsent((consentGatheringError) {
      if (consentGatheringError != null) {
        // Consent not obtained in current session.
        debugPrint(
            "${consentGatheringError.errorCode}: ${consentGatheringError.message}");
      }

      // Check if a privacy options entry point is required.
      _getIsPrivacyOptionsRequired();

      // Attempt to initialize the Mobile Ads SDK.
      _initializeMobileAdsSDK();
    });

    // This sample attempts to load ads using consent obtained in the previous session.
    _initializeMobileAdsSDK();
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

  //widget para meter mail
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

  //widget para meter contraseña
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

  //boton para realizar el login
  Widget _loginButton(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          //metodo de login
          onPressed: () async{//empieza funcion
            if(_formKey.currentState!.validate()){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conectando...espera unos segundos', style: TextStyle(color: Colors.white,)),backgroundColor: Colors.orange),
              );
              DatosUsuario datos = await login(_user,_password);
              if(datos.mensaje == "ok"){
                _interstitialAd?.show();
                //se va a las rondas del usuario
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

  //boton crear usuario
  Widget _createrUserButton(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          child: const Text('Crear usuario', style: TextStyle(color: Colors.white, fontSize: 15.0,)),
          onPressed: () {
            //se va a la creacion del usuario
            Navigator.push(context, MaterialPageRoute(builder: (context)=> CreaterUserScreen()));
          }
      ),
    );
  }

  //construcion de widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar
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
          //formulario login
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

  //llamada a la api de login
  Future<DatosUsuario> login(mail,password) async {
    final response = await http
        .get(Uri.parse(_link+'?action=login&mail='+mail+'&password=Z'+password));
    if (response.statusCode == 200) {
      return DatosUsuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fallo al acceder a la api');
    }
  }

  /// Redraw the app bar actions if a privacy options entry point is required.
  void _getIsPrivacyOptionsRequired() async {
    if (await _consentManager.isPrivacyOptionsRequired()) {
      setState(() {
        _isPrivacyOptionsRequired = true;
      });
    }
  }

  /// Initialize the Mobile Ads SDK if the SDK has gathered consent aligned with
  /// the app's configured messages.
  void _initializeMobileAdsSDK() async {
    if (_isMobileAdsInitializeCalled) {
      return;
    }

    if (await _consentManager.canRequestAds()) {
      _isMobileAdsInitializeCalled = true;

      // Initialize the Mobile Ads SDK.
      MobileAds.instance.initialize();
      _loadAd();
    }
  }

}