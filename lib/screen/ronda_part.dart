import 'package:flutter/material.dart';
import 'package:adiapp/model/usuario.dart';
import 'package:adiapp/model/ronda.dart';
import '../model/participante.dart';
import 'anyadir_participante.dart';
import 'datos_ronda.dart';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
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
        body: Center(
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) => _listItem(context, _data[index]),
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

  //metodo para ver si se puede añadir participantes y enseñar e boton
  Widget _botonModificar(context){
    if(ronda.mail == usuario.mail){
      return IconButton(
        onPressed: () {
          //se va a la pantalla de añadir participante
          Navigator.push(context, MaterialPageRoute(builder: (context)=> ParticipanteScreen(usuario,ronda)));
        },
        icon: Icon(Icons.add_circle,color: Colors.white),
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

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
  }
}