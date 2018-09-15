import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'database/database.dart';
import 'home.dart';
import 'screens/account_profile.dart';
import 'screens/account_solde.dart';
import 'screens/confirmation.dart';
import 'screens/search.dart';
import 'screens/signin.dart';
import 'screens/signup.dart';

void main() => runApp(MyApp());

const String title = 'Campaign';

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  AppDatabase db;

  @override
  void initState() {
    super.initState();
    db = AppDatabase();
    db.initDB();
    checkPermission();
  }
  
  @override
  void dispose() {      
    db.closeDb();
    super.dispose();
  }

  void checkPermission() async {
    await SimplePermissions.requestPermission(Permission.RecordAudio);
    await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
  }

  Widget _applyTestScaleFactor(Widget child) {
    return Builder(
      builder: (BuildContext context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
            devicePixelRatio: null
          ),
          child: child,
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      builder: (BuildContext context, Widget child){
        return Directionality(
          textDirection: TextDirection.ltr,
          child: _applyTestScaleFactor(child),
        );
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        // fontFamily: 'Product Sans'
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/profile': (context) => ProfileScreen(),
        '/solde': (context) => SoldeScreen(),
        '/confirmation': (context) => ConfirmationScreen(),
        '/search': (context) => SearchScreen(),
        '/signin': (context) => SigninScreen(),
        '/signup': (context) => SignupScreen(),
      },
    );
  }
}