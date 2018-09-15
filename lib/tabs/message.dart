import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import '../model/model.dart';
import '../database/database.dart';
import '../placeholders/empty_message.dart';
import '../screens/edit_sms.dart';
import '../screens/edit_voice.dart';
import '../screens/add_sms.dart';
import '../screens/add_voice.dart';
import 'dart:async';

class Message extends StatefulWidget {
  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _mainKey = GlobalKey<ScaffoldState>();
  AppDatabase db = AppDatabase();
  List<Messaging> messages = List();

  @override
  void initState() {
    super.initState();
    getMessages();
    // if (messages.isNotEmpty) {
    //   messages.map((m) {
    //     if (m.status == 0) {
    //       db.updateMessage(m);
    //     }
    //   });
    // }
  }
  
  @override
  didPopRoute() {
    getMessages();
    super.didPopRoute();
  }

  Future<void> getMessages() async {
    List<Messaging> _messages = await db.getMessages();
    _messages.sort((lhs, rhs) => rhs.id.compareTo(lhs.id));
    setState(() {
      messages = _messages;
    });
  }

  void onDeleteMessage(Messaging message) {
    setState(() {
      messages.remove(message);
    });
    db.deleteMessage(message.id);
    setState(() {});
    getMessages();
    setState(() {});
  }

  void _shouldUpdateList(bool value) {
    Navigator.of(context).pop();
    getMessages();
    setState(() {});
    _mainKey.currentState.showSnackBar(SnackBar(
      content: Text('Message modifié'),
    ));
  }

  void _shouldAddList(bool value) {
    Navigator.of(context).pop();
    getMessages();
    setState(() {});
    _mainKey.currentState.showSnackBar(SnackBar(
      content: Text('Message ajouté'),
    ));
  }

  void _shouldSendMessage(Messaging message) {    
    _mainKey.currentState.showSnackBar(SnackBar(
      content: Text('Message envoyé'),
    ));
    onSendMessage(message);
  }

  void onSendMessage(Messaging message) async {
    await db.onSendMessage(message);
    setState(() {});
    getMessages();
    setState(() {});
  }

  void handleUndo(Messaging message) async {
    setState(() {
      messages.add(message);
    });
    db.saveMessage(message);
  }

  String dateFormatter(createdAt) {
    return formatDate(createdAt, [dd,'/',mm,'/',yyyy,' à ',HH,':',nn,':',ss]);
  }

  String audioName(path) {
    final RegExp regExp1 = RegExp('([^?/]*\.(m4a))');
    final RegExp regExp2 = RegExp('([^?/]*\.(mp3))');
    final RegExp regExp3 = RegExp('([^?/]*\.(aac))');
    String pathName;
    if (regExp1.hasMatch(path.toString())) {
      pathName =
          regExp1.stringMatch(path.toString().trim().replaceAll(' ', ''));
    } else if (regExp2.hasMatch(path.toString())) {
      pathName =
          regExp2.stringMatch(path.toString().trim().replaceAll(' ', ''));
    }
    if (regExp3.hasMatch(path.toString())) {
      pathName =
          regExp3.stringMatch(path.toString().trim().replaceAll(' ', ''));
    }
    return pathName;
  }

  Widget _buildRow(BuildContext context, Messaging message) {
    final ThemeData theme = Theme.of(context);

    return Dismissible(
      key: ObjectKey(message),
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.dividerColor))),
        child: ListTile(
          title: message.messageType == 'SMS' ? Text(message.content, overflow: TextOverflow.ellipsis, 
          maxLines: 1,) : Text('${audioName(message.cachedUrl)}', overflow: TextOverflow.ellipsis, maxLines: 1,),
          subtitle: Row(children: <Widget>[message.status == 3
                ? Row(children: <Widget>[
                      Expanded(child: Row(children: <Widget>[
                        Icon(Icons.check_circle,color: Theme.of(context).primaryColor,size: 14.0,),
                        SizedBox(width: 4.0,),
                        Text('Crée le ${message.createdAt}',maxLines: 1,overflow: TextOverflow.ellipsis,style: Theme.of(context).textTheme.caption,)
                      ]))])
                : Expanded(child: Text('Crée le ${message.createdAt}',maxLines: 1,overflow: TextOverflow.ellipsis,style: Theme.of(context).textTheme.caption,))
          ]),
          trailing: Icon(Icons.chevron_right),
          leading: message.messageType == 'VOICE' ? Icon(Icons.keyboard_voice) : Icon(Icons.email),
          onTap: () {
            return message.messageType == 'SMS' ? Navigator.push(context, MaterialPageRoute(builder: (context) => EditSMSScreen(
              message: message, 
              shouldUpdateList: _shouldUpdateList,
              shouldSendMessage: _shouldSendMessage,)))

                : Navigator.push(context, MaterialPageRoute(builder: (context) => EditVoiceScreen(
                  message: message, 
                  shouldUpdateList: _shouldUpdateList,
                  shouldSendMessage: _shouldSendMessage,)));
          },
        ),
      ),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: theme.primaryColor,
        child: const ListTile(
          leading: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 26.0,
          ),
        ),
      ),
      onDismissed: (DismissDirection direction) {
        final String action = message.messageType == 'SMS' ? 'ce SMS' : 'cet audio';
        onDeleteMessage(message);
        _mainKey.currentState.showSnackBar(SnackBar(
          content: Text('Vous avez supprimer $action'),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () {
              handleUndo(message);
            },
          ),
        ));
      },
    );
  }

  Widget getBody() {
    if (messages.isEmpty) return MessagePlaceholder();
    return ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) => _buildRow(context, messages[index]));
  }

  void createMessageDialog(BuildContext context) {
    TextStyle contentStyle = Theme.of(context).textTheme.title;
    TextStyle titleStyle = Theme.of(context).textTheme.subhead.copyWith(fontFamily: 'Product Sans');

    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              'Créer un message'.toUpperCase(),
              style: titleStyle,
            ),
            titlePadding: EdgeInsets.fromLTRB(20.0, 16.0, 8.0, 0.0),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            children: <Widget>[
              FlatButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.email, color: Colors.black54),
                    SizedBox(width: 12.0),
                    Text(
                      'SMS',
                      style: contentStyle,
                    )
                  ],
                ),
                onPressed: () {
                  // Navigator.of(context).pop();
                  return Navigator.push(context, MaterialPageRoute(
                    builder: (context) => AddSMSScreen(
                      shouldSendMessage: _shouldSendMessage,
                      shouldAddList: _shouldAddList))
                  );
                },
              ),
              Divider(),
              FlatButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.keyboard_voice, color: Colors.black54),
                    SizedBox(width: 12.0),
                    Text(
                      'AUDIO',
                      style: contentStyle,
                    ),
                  ],
                ),
                onPressed: () {
                  // Navigator.of(context).pop();
                  return Navigator.push(context, MaterialPageRoute(
                    builder: (context) => AddVoiceScreen(
                      shouldSendMessage: _shouldSendMessage,
                      shouldAddList: _shouldAddList))
                  );
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _mainKey,
      body: RefreshIndicator(
        onRefresh: () async {
          await getMessages();
          setState(() {});
        },
        child: getBody(),
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 2.5,
          backgroundColor: Colors.red,
          child: Icon(Icons.add),
          tooltip: 'Créer un message',
          onPressed: () => createMessageDialog(context)),
    );
  }
}