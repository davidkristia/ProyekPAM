import 'package:flutter/material.dart';
import 'package:flutter_2/pages/editinfokapal.dart';
import 'package:flutter_2/pages/tambahnahkoda.dart';
import 'package:flutter_2/pages/tambahpemilikkapal.dart';
import 'package:flutter_2/pages/transaksikapal.dart';
import 'package:flutter_2/pages/welcome_pages.dart';
import 'package:flutter_2/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/home': (context) => HomePage(),
        '/editKapal': (context) => EditInfoPage(),
        '/transaksiKapal': (context) => TransaksiKapalPage(),
        '/tambahPemilikKapal': (context) => TambahPemilikKapalPage(),
        '/tambahNahkoda': (context) => TambahNahkodaPage(),
      },
    );
  }
}
