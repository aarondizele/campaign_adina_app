import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../model/model.dart';
import '../database/database.dart';
import '../dialogs/select_district.dart';
import 'package:date_format/date_format.dart';

class AddSMSScreen extends StatefulWidget {
  final ValueChanged<bool> shouldAddList;
  final ValueChanged<Messaging> shouldSendMessage;

  const AddSMSScreen({Key key, @required this.shouldAddList, this.shouldSendMessage,}) : super(key: key);
  @override
  _AddSMSScreenState createState() => _AddSMSScreenState();
}

class _AddSMSScreenState extends State<AddSMSScreen> {
  final GlobalKey<ScaffoldState> _addSMSKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _addSMSFormKey = GlobalKey<FormState>();
  AppDatabase db = AppDatabase();
  TextEditingController _contentController = TextEditingController();
  String district = '', province = '';

  void _onSelectValues(values) {
    setState(() {
      district = values["district"];
      province = values["province"];
    });
  }

  void sendMessage() {
    if (!_addSMSFormKey.currentState.validate()) return;

    if (district.isEmpty) {
      _addSMSKey.currentState.showSnackBar(SnackBar(
        content: Text('Veuillez sélectionner une ville'),
      ));
      return;
    }

    Messaging _message = Messaging(
      messageType: 'SMS',
      createdAt: formatDate(DateTime.now(), [dd,'/',mm,'/',yyyy,' à ',HH,':',nn,':',ss]),
      timestamp: DateTime.now().toIso8601String(),
      userId: 'Tipo-Tipo',
      content: _contentController.text,
      mediaUrl: "",
      district: district,
      province: province,
      cachedUrl: "",
      status: 1,
      statusName: 'sync',
    );
    // db.sendToServer(_message);
    widget.shouldSendMessage(_message);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void saveMessage() {
    if (!_addSMSFormKey.currentState.validate()) return;

    Messaging _message = Messaging(
      messageType: 'SMS',
      createdAt: formatDate(DateTime.now(), [dd,'/',mm,'/',yyyy,' à ',HH,':',nn,':',ss]),
      timestamp: DateTime.now().toIso8601String(),
      userId: 'Tipo-Tipo',
      content: _contentController.text,
      mediaUrl: "",
      district: district,
      province: province,
      cachedUrl: "",
      status: 1,
      statusName: 'sync',
    );
    db.saveMessage(_message);
    widget.shouldAddList(true);
    _contentController.clear();
    Navigator.of(context).pop();
  }

  Widget _getBody() {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor))),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              trailing: Icon(Icons.arrow_drop_down),
              title: district == '' ? Text('Sélectionner une ville', overflow: TextOverflow.ellipsis, maxLines: 1) : Text(district, overflow: TextOverflow.ellipsis, maxLines: 1),
              onTap: () {
                showDialog(context: context, builder: (context) => SelectDistrict(onSelectValues: _onSelectValues,));
              },
            ),
          ),
          SizedBox(height: 16.0,),
          Form(
            key: _addSMSFormKey,
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
      key: _addSMSKey,
      appBar: AppBar(
        title: Text('Retour', style: TextStyle(fontFamily: 'Product Sans'),),
        elevation: 2.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveMessage,
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: sendMessage,
          ),
        ]),
      body: _getBody()
    );
  }
}