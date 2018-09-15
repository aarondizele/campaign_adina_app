import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../model/model.dart';
import '../database/database.dart';
import '../dialogs/select_district.dart';

class EditSMSScreen extends StatefulWidget {
  final ValueChanged<bool> shouldUpdateList;
  final ValueChanged<Messaging> shouldSendMessage;
  final Messaging message;

  const EditSMSScreen({Key key, @required this.shouldUpdateList, @required this.message, this.shouldSendMessage,}) : super(key: key);
  @override
  _EditSMSScreenState createState() => _EditSMSScreenState();
}

class _EditSMSScreenState extends State<EditSMSScreen> {
  final GlobalKey<ScaffoldState> _editSMSKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _editSMSFormKey = GlobalKey<FormState>();
  AppDatabase db = AppDatabase();
  Messaging message;
  TextEditingController _contentController = TextEditingController();
  String district = '', province = '';

  @override
  void initState() {
    super.initState();
    message = widget.message;
    district = widget.message.district;
    province = widget.message.province;
    _contentController.text = widget.message.content;
  }

  void _onSelectValues(values) {
    setState(() {
      district = values["district"];
      province = values["province"];
    });
  }

  void sendMessage() {
    if (!_editSMSFormKey.currentState.validate()) return;

    if (district.isEmpty) {
      _editSMSKey.currentState.showSnackBar(SnackBar(
        content: Text('Veuillez sélectionner une ville'),
      ));
      return;
    }

    Messaging _message = Messaging(
      id: message.id,
      messageType: message.messageType,
      createdAt: message.createdAt,
      timestamp: message.timestamp,
      userId: message.userId,
      content: _contentController.text,
      mediaUrl: message.mediaUrl,
      district: district,
      province: province,
      cachedUrl: message.cachedUrl,
      status: message.status,
      statusName: message.statusName
    );
    // db.onSendMessage(_message);
    widget.shouldSendMessage(_message);
    Navigator.of(context).pop();
  }

  void saveMessage() {
    if (!_editSMSFormKey.currentState.validate()) return;

    Messaging _message = Messaging(
      id: message.id,
      messageType: message.messageType,
      createdAt: message.createdAt,
      timestamp: message.timestamp,
      userId: message.userId,
      content: _contentController.text,
      mediaUrl: message.mediaUrl,
      district: district,
      province: province,
      cachedUrl: message.cachedUrl,
      status: message.status,
      statusName: message.statusName,
    );
    db.updateMessage(_message);
    _contentController.clear();
    widget.shouldUpdateList(true);
    // Navigator.of(context).pop();
  }

  Widget _getBody() {
    final ThemeData theme = Theme.of(context);
    TextStyle textSize = Theme.of(context).textTheme.subhead;
    TextStyle captionStyle =
        Theme.of(context).textTheme.caption.copyWith(color: Colors.black54);
        
    return message.statusName == "sent" ? Container(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        children: <Widget>[
          Column(children: <Widget>[
            Row(children: <Widget>[
              Icon(Icons.calendar_today, size: 14.0),
              SizedBox(width: 6.0,),
              Text('Crée le ${message.createdAt}')
            ],),
            SizedBox(width: 10.0,),
            Row(children: <Widget>[
              Icon(Icons.check_circle, size: 14.0),
              SizedBox(width: 6.0,),
              Text('Envoyé à: ${message.district}')
              // Text('Envoyé à: ${message.district} - ${message.province}')
            ],),
          ],),
          SizedBox(height: 16.0,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Message', style: captionStyle),
              SizedBox(height: 4.0),
              Text(message.content, style: textSize)
            ],
          ),
        ],
      ),
    ) : Container(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor))),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              trailing: Icon(Icons.arrow_drop_down),
              title: district.isNotEmpty ? Text(district) : Text('Sélectionner une ville', overflow: TextOverflow.ellipsis, maxLines: 1),
              onTap: () {
                showDialog(context: context, builder: (context) => SelectDistrict(onSelectValues: _onSelectValues,));
              },
            ),
          ),
          SizedBox(height: 16.0,),
          Form(
            key: _editSMSFormKey,
            child: TextFormField(
              maxLines: 3,
              validator: (String value){
                if (value.isEmpty) {
                  return 'Veuillez saisir votre message';
                }
              },
              controller: _contentController,
              decoration: InputDecoration(
                hintText: 'Message', labelText: 'Écrivez votre message'
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _editSMSKey,
      appBar: AppBar(
        title: Text('Retour', style: TextStyle(fontFamily: 'Product Sans'),),
        elevation: 2.0,
        actions: message.statusName == "sent" ? <Widget>[] : <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveMessage,
          ),
          message.status == 0 ? IconButton(
            disabledColor: Colors.white,
            onPressed: null,
            icon: Icon(Icons.more_horiz),
          ) : IconButton(
            icon: Icon(Icons.send),
            onPressed: sendMessage,
          ),
        ]),
      body: _getBody()
    );
  }
}