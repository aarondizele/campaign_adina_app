import 'package:flutter/material.dart';

class SoldeScreen extends StatefulWidget {
  @override
  _SoldeScreenState createState() => _SoldeScreenState();
}

class _SoldeScreenState extends State<SoldeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon solde', style: TextStyle(fontFamily: 'Product Sans'),),
      ),
    );
  }
}