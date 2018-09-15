import 'package:flutter/material.dart';

class MessagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[ Expanded( child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center, 
          children: <Widget>[
                  Icon(Icons.inbox, size: 100.0, color: Colors.black87),
                  SizedBox(
                    height: 6.0,
                  ),
                  Text(
                    "Vous n'avez pas des messages",
                    textAlign: TextAlign.center,
                    style: Theme
                        .of(context)
                        .textTheme
                        .title
                        .copyWith(color: Colors.black54, fontFamily: 'Product Sans'),
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    'Veuillez créer un message AUDIO ou SMS',
                    textAlign: TextAlign.center,
                    style: Theme
                        .of(context)
                        .textTheme
                        .caption
                        .copyWith(color: Colors.black54),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
