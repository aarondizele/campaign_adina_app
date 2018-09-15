import 'package:flutter/material.dart';
import 'model/model.dart';
import 'database/database.dart';
import 'tabs/collect.dart';
import 'tabs/graph.dart';
import 'tabs/message.dart';
import 'dart:async';
import 'package:connectivity/connectivity.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppDatabase db = AppDatabase();
  List<Messaging> messages = List();
  final Connectivity connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    getMessages();
    connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
       if (messages.isNotEmpty) {
          List<Messaging> messagesToUpdate = messages.where((m) => m.status == 0);
          return messagesToUpdate.map((m) => db.updateMessage(m));
        } 
      }
    });
  }

  Future<void> getMessages() async {
    List<Messaging> _messages = await db.getMessages();
    _messages.sort((lhs, rhs) => rhs.id.compareTo(lhs.id));
    setState(() {
      messages = _messages;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle _style = TextStyle(color: Colors.black87, fontSize: 16.0);
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Campaign", style: TextStyle(fontFamily: 'Product Sans'),),
          elevation: 2.0,
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              // onPressed: () => Navigator.of(context).pushNamed('/search'),
              icon: Icon(Icons.search),
            )
          ],
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: 'MESSAGE'),
              Tab(text: 'COLLECTE'),
              Tab(text: 'GRAPHE'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor
                ),
                accountName: Text('Adina Dizele',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                accountEmail: Text('+243810000000'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text('A', style: Theme.of(context).textTheme.display3.copyWith(color: Theme.of(context).primaryColor)),
                ),
              ),
              ListTile(
                title: Text('Mon solde', style: _style),
                leading: Icon(Icons.payment, color: Colors.black87),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/solde');
                },
              ),
              ListTile(
                title: Text('Mon compte', style: _style),
                leading: Icon(Icons.account_circle, color: Colors.black87),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/profile');
                },
              ),
              ListTile(
                title: Text('À propos', style: _style),
                leading: Icon(Icons.info, color: Colors.black87),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Se déconnecter', style: _style),
                leading: Icon(Icons.exit_to_app, color: Colors.black87),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Message(),
            Collect(),
            Graph()
          ],
        ),
      ),
    );
  }
}