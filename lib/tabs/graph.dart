import 'package:flutter/material.dart';
import '../placeholders/coming_soon.dart';

class Graph extends StatefulWidget {
  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  @override
  Widget build(BuildContext context) {
    return ComingSoonContent();
  }
}