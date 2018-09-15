import 'package:flutter/material.dart';
import 'package:stereo/stereo.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'dart:io';
import 'dart:async';
import '../model/model.dart';
import '../database/database.dart';
import '../dialogs/select_district.dart';

enum PlayerState { stopped, playing, paused }

class EditVoiceScreen extends StatefulWidget {
  final ValueChanged<bool> shouldUpdateList;
  final ValueChanged<Messaging> shouldSendMessage;
  final Messaging message;

  const EditVoiceScreen({Key key, this.shouldUpdateList, @required this.message, this.shouldSendMessage}) : super(key: key);
  @override
  _EditVoiceScreenState createState() => _EditVoiceScreenState();
}

class _EditVoiceScreenState extends State<EditVoiceScreen> {
  final GlobalKey<ScaffoldState> _editVoicedKey = GlobalKey<ScaffoldState>();
  // 
  AppDatabase db = AppDatabase();
  Messaging message;
  Stereo _myStereo = Stereo();
  Recording _myRecording = Recording();
  Stopwatch watch = Stopwatch();
  // 
  String province, district, cachedUrl;
  bool _myIsFileAttached;
  bool _myIsRecording;
  bool _myIsPlaying;
  bool _myIsRecorded;
  // 
  static const Icon _pauseIcon = Icon(Icons.pause);
  static const Icon _playIcon = Icon(Icons.play_arrow);
  static const Icon _stopingIcon = Icon(Icons.stop);
  // 
  Duration duration;
  Duration position;
  AudioPlayer audioPlayer;
  // 
  PlayerState playerState = PlayerState.stopped;
  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;
  // 
  StreamSubscription _audioPlayerStateSubscription;
  StreamSubscription _positionSubscription;
  // 
  // Stopwatch
  Timer timer;
  String elapsedTime = '';

  @override
  void initState() {
    super.initState();
    myResetWatch();
    message = widget.message;
    cachedUrl = message.cachedUrl;
    district = message.district;
    province = message.province;
    _myIsFileAttached = true;
    _myIsRecording = false;
    _myIsPlaying = false;
    _myIsRecorded = false;
    _initAudioPlayer();
    print(message.toMap());
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void _initAudioPlayer() {
    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() {
          _myIsPlaying = true;
          duration = audioPlayer.duration;
        });
      } else if (s == AudioPlayerState.STOPPED) {
        _onComplete();
        setState(() {
          _myIsPlaying = false;
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  void _onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  Future myPlay() async {
    await audioPlayer.play(cachedUrl, isLocal: true);
    setState(() {
      playerState = PlayerState.playing;
      _myIsPlaying = true;
    });
  }

  Future myPause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future myStop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = Duration();
    });
  }

  Widget _playerControls() {
    IconButton _iconButton;
    if (isPaused) {
      _iconButton = IconButton(
        icon: _playIcon,
        onPressed: myPlay,
        color: Theme.of(context).primaryColor);
    } else if (isPlaying) {
      _iconButton = IconButton(
        icon: _pauseIcon,
        onPressed: myPause,
        color: Theme.of(context).primaryColor);
    } else {
      _iconButton = IconButton(
        icon: _playIcon,
        onPressed: myPlay,
        color: Theme.of(context).primaryColor);
    }
    return _iconButton;
  }

  double _myGetSliderValue() {
    int _position = position?.inMilliseconds ?? 0;
    if (_position <= 0) {
      return 0.0;      
    } else if (_position >= position?.inMilliseconds) {
      return position?.inMilliseconds?.toDouble();      
    } else {
      return _position.toDouble();
    }
  }

  bool myResetState() {
    if (_myIsPlaying || _myIsFileAttached || _myIsRecorded) {
      return true;
    }
    return false;
  }

  String get myTimerString {
    Duration duration = _myRecording.duration;
    return duration == null
        ? '00:00:00'
        : '${(duration.inHours).toString().padLeft(2, '0')}:${(duration.inMinutes).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Widget _myGetPlayer() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _playerControls(),
          duration == null ? Expanded(child: Slider(
            value: 0.0,
            min: 0.0,
            max: 0.0,
            onChanged: null,
          )) : Expanded(child: Slider(
            value: _myGetSliderValue(),
            onChanged: (double value) =>
                audioPlayer.seek((value / 1000).roundToDouble()),
            min: 0.0,
            max: duration.inMilliseconds.toDouble()),
          )
        ],
      ),
    );
  }

  // Stopwatch Functions
  myUpdateTime(Timer timer) {
    if (watch.isRunning) {
      setState(() {
        elapsedTime = _transformMilliSeconds(watch.elapsedMilliseconds);
      });
    }
  }
  // 
  myStartWatch() {
    watch.start();
    timer = new Timer.periodic(new Duration(milliseconds: 100), myUpdateTime);
  }
  // 
  myStopWatch() {
    watch.stop();
    mySetTime();
  }
  // 
  myResetWatch() {
    watch.reset();
    mySetTime();
  }
  // 
  mySetTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = _transformMilliSeconds(timeSoFar);
    });
  }
  // 
  _transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 24).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return "$hoursStr:$minutesStr:$secondsStr";
  }

  void _myOnSelectValues(values) {
    setState(() {
      district = values["district"];
      province = values["province"];
    });
  }

  void mySendMessage() {    
    if (district.isEmpty) {
      _editVoicedKey.currentState.showSnackBar(SnackBar(
        content: Text('Veuillez sélectionner une ville'),
      ));
      return;
    }
    if (cachedUrl == '') {
      _editVoicedKey.currentState.showSnackBar(SnackBar(
        content: Text('Veuillez enregistrer un message vocal'),
      ));
      return;
    }
    Messaging _message = Messaging(
      id: message.id,
      messageType: message.messageType,
      createdAt: message.createdAt,
      timestamp: message.timestamp,
      userId: message.userId,
      content: message.content,
      mediaUrl: message.mediaUrl,
      district: district,
      province: province,
      cachedUrl: message.cachedUrl,
      status: message.status,
      statusName: message.statusName
    );
    // db.sendToServer(_message);
    widget.shouldSendMessage(_message);
    Navigator.of(context).pop();
  }

  void updateMessage() {
    if (cachedUrl == '') {
      _editVoicedKey.currentState.showSnackBar(SnackBar(
        content: Text('Veuillez enregistrer un message vocal...'),
      ));
      return;
    }

    Messaging _message = Messaging(
      id: message.id,
      messageType: message.messageType,
      createdAt: message.createdAt,
      timestamp: message.timestamp,
      userId: message.userId,
      content: message.content,
      mediaUrl: message.mediaUrl,
      district: district,
      province: province,
      cachedUrl: message.cachedUrl,
      status: message.status,
      statusName: message.statusName,
    );
    
    db.updateMessage(_message);
    widget.shouldUpdateList(true);
    // Navigator.of(context).pop();
  }

  String get audioName {
    final RegExp regExp1 = RegExp('([^?/]*\.(m4a))');
    final RegExp regExp2 = RegExp('([^?/]*\.(mp3))');
    final RegExp regExp3 = RegExp('([^?/]*\.(aac))');
      String pathName;
    if (regExp1.hasMatch(cachedUrl.toString())) {
      pathName = regExp1.stringMatch(cachedUrl.toString().trim().replaceAll(' ', ''));
    } else if (regExp2.hasMatch(cachedUrl.toString())) {
      pathName = regExp2.stringMatch(cachedUrl.toString().trim().replaceAll(' ', ''));
    }
    if (regExp3.hasMatch(cachedUrl.toString())) {
      pathName = regExp3.stringMatch(cachedUrl.toString().trim().replaceAll(' ', ''));
    }
    return pathName;
  }

  Future onPickFile() async {
    try {
      AudioTrack track = await _myStereo.picker();
      setState(() {
        _myIsFileAttached = true;
        cachedUrl = track.path;
      });      
    } on StereoPermissionsDeniedException catch (_) {
      print('ERROR: Permissions denied');
    } on StereoNoTrackSelectedException {
      print('ERROR: No track selected');
    }
  }

  _starting() async {
    try {
      if (await AudioRecorder.hasPermissions) {
        final Directory tempDir = Directory.systemTemp;
        final String path = tempDir.path;
        await AudioRecorder.start(audioOutputFormat: AudioOutputFormat.AAC);
        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _myIsFileAttached = false;
          cachedUrl = '';
          _myRecording = Recording(duration: Duration(), path: '');
          _myIsRecording = isRecording;
        });
        myStartWatch();
      } else {
        Scaffold
            .of(context)
            .showSnackBar(SnackBar(content: Text('Ne peut pas enregistrer.')));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  _stoping() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    File file = await File(recording.path);
    setState(() {
      _myRecording = recording;
      _myIsRecording = isRecording;
      _myIsRecorded = true;
      _myIsFileAttached = true;
      cachedUrl = _myRecording.path;
    });
    myStopWatch();
  }

  Widget onGetRecorder() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
        Text(
          '$elapsedTime', style: TextStyle(fontSize: 38.0, color: Colors.red,)
        ),
      ],)
    );
  }

  Widget onGetBody() {
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
            SizedBox(height: 10.0,),
            Row(children: <Widget>[
              Icon(Icons.check_circle, size: 14.0),
              SizedBox(width: 6.0,),
              Text('Envoyé à: ${message.district}')
            ]),
          ]),
          SizedBox(height: 16.0,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _myGetPlayer(),
              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Icon(Icons.attach_file, size: 14.0,),
                      SizedBox(width: 4.0,),
                      Text(audioName, style: theme.textTheme.caption)
                    ],),)
                ],
              ),
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
                showDialog(context: context, builder: (context) => SelectDistrict(onSelectValues: _myOnSelectValues,));
              },
            ),
          ),
          SizedBox(height: 16.0,),
          Container(
           child: Text('Enregistrement audio', textAlign: TextAlign.center,), 
          ),
          _myIsFileAttached ? Column(
            children: <Widget>[
              _myGetPlayer(),
              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Icon(Icons.attach_file, size: 14.0,),
                      SizedBox(width: 4.0,),
                      Text(audioName, style: theme.textTheme.caption)
                    ],),)
                ],
              ),
            ],
          ) : Column(children: <Widget>[onGetRecorder()]),
          SizedBox(height: 16.0,),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: <Widget>[
          //     myResetState() ? FloatingActionButton(
          //       child: Icon(Icons.replay),
          //       elevation: 0.0,
          //       onPressed: () {
          //         setState(() {
          //           _myIsFileAttached = false;
          //           _myIsPlaying = false;
          //           _myIsRecorded = false;
          //         });
          //         myResetWatch();
          //         myStop();
          //       },
          //     )
          //   : (_myIsRecording
          //       ? FloatingActionButton(
          //           backgroundColor: Colors.red,
          //           elevation: 0.0,
          //           onPressed: _myIsRecording ? _stoping : null,
          //           child: Icon(Icons.stop),
          //         )
          //       : FloatingActionButton(
          //           elevation: 0.0,
          //           onPressed: _myIsRecording ? null : _starting,
          //           child: Icon(Icons.keyboard_voice)
          //         )
          //     ),                
          //     FloatingActionButton(
          //         elevation: 0.0,
          //         child: Icon(Icons.attach_file),
          //         onPressed: () {
          //           onPickFile();
          //           setState(() {
          //             _myIsRecording = false;
          //             _myIsPlaying = false;
          //           });
          //           myStop();
          //         },
          //       ),
          //   ],
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _editVoicedKey,
      appBar: AppBar(
        title: Text('Retour'),
        elevation: 2.0,
        actions: message.statusName == "sent" ? <Widget>[] : <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: updateMessage,
          ),
          message.status == 0 ? IconButton(
            disabledColor: Colors.white,
            onPressed: null,
            icon: Icon(Icons.more_horiz),
          ) : IconButton(
            icon: Icon(Icons.send),
            onPressed: mySendMessage,
          ),
        ]),
      body: Semantics(
        child: onGetBody(),
      )
    );
  }
}