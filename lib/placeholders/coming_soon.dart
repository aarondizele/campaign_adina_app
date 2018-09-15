import 'package:flutter/material.dart';

class ComingSoonContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                  "Bientôt disponible",
                  textAlign: TextAlign.center,
                  style: Theme
                      .of(context)
                      .textTheme
                      .title
                      .copyWith(color: Colors.black54, fontFamily: 'Product Sans'),
                ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
