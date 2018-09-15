import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:stereo/stereo.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import '../model/model.dart';
import '../database/database.dart';
import '../dialogs/select_district.dart';

enum PlayerState { stopped, playing, paused }

class AddVoiceScreen extends StatefulWidget {
  final ValueChanged<bool> shouldAddList;
  final ValueChanged<Messaging> shouldSendMessage;

  const AddVoiceScreen({Key key, this.shouldAddList, this.shouldSendMessage}) : super(key: key);
  @override
  _AddVoiceScreenState createState() => _AddVoiceScreenState();
}

class _AddVoiceScreenState extends State<AddVoiceScreen> {
  final GlobalKey<ScaffoldState> _addVoicedKey = GlobalKey<ScaffoldState>();
  // 
  AppDatabase db = AppDatabase();
  Stereo _stereo = Stereo();
  Recording _recording = Recording();
  Stopwatch watch = Stopwatch();
  // 
  String province = '', district = '', cachedUrl = '';
  bool _isFileAttached;
  bool _isRecording;
  bool _isPlaying;
  bool _isRecorded;
  // 
  static const Icon _pauseIcon = Icon(Icons.pause, size: 20.0);
  static const Icon _playIcon = Icon(Icons.play_arrow, size: 20.0);
  static const Icon _stopIcon = Icon(Icons.stop, size: 20.0);
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
    _isFileAttached = false;
    _isRecording = false;
    _isPlaying = false;
    _isRecorded = false;
    initAudioPlayer();
    resetWatch();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() {
          _isPlaying = true;
          duration = audioPlayer.duration;
        });
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          _isPlaying = false;
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

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  Future play() async {
    await audioPlayer.play(cachedUrl, isLocal: true);
    setState(() {
      playerState = PlayerState.playing;
      _isPlaying = true;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = Duration();
    });
  }

  Widget playerControls() {
    IconButton _iconButton;
    if (isPaused) {
      _iconButton = IconButton(
        icon: _playIcon,
        onPressed: play,
        color: Theme.of(context).primaryColor);
    } else if (isPlaying) {
      _iconButton = IconButton(
        icon: _pauseIcon,
        onPressed: pause,
        color: Theme.of(context).primaryColor);
    } else {
      _iconButton = IconButton(
        icon: _playIcon,
        onPressed: play,
        color: Theme.of(context).primaryColor);
    }
    return _iconButton;
  }

  double _getSliderValue() {
    int _position = position?.inMilliseconds ?? 0;
    if (_position <= 0) {
      return 0.0;      
    } else 
    if (_position >= position?.inMilliseconds) {
      return position?.inMilliseconds?.toDouble();      
    } else {
      return _position.toDouble();
    }
  }

  bool resetState() {
    if (_isPlaying || _isFileAttached || _isRecorded) {
      return true;
    }
    return false;
  }

  String get timerString {
    Duration duration = _recording.duration;
    return duration == null
        ? '00:00:00'
        : '${(duration.inHours).toString().padLeft(2, '0')}:${(duration.inMinutes).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Widget getPlayer() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          playerControls(),
          duration == null ? Expanded(child: Slider(
            value: 0.0,
            min: 0.0,
            max: 0.0,
            onChanged: null,
          )) : Expanded(child: Slider(
            value: _getSliderValue(),
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
  updateTime(Timer timer) {
    if (watch.isRunning) {
      setState(() {
        elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
      });
    }
  }
  // 
  startWatch() {
    watch.start();
    timer = new Timer.periodic(new Duration(milliseconds: 100), updateTime);
  }
  // 
  stopWatch() {
    watch.stop();
    setTime();
  }
  // 
  resetWatch() {
    watch.reset();
    setTime();
  }
  // 
  setTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformMilliSeconds(timeSoFar);
    });
  }
  // 
  transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 24).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return "$hoursStr:$minutesStr:$secondsStr";
  }

  void _onSelectValues(values) {
    setState(() {
      district = values["district"];
      province = values["province"];
    });
  }

  void sendMessage() {    
    if (district.isEmpty) {
      _addVoicedKey.currentState.showSnackBar(SnackBar(
        // content: Text('Veuillez sélectionner un district'),
        content: Text('Veuillez sélectionner une ville'),
      ));
      return;
    }
    if (cachedUrl == '') {
      _addVoicedKey.currentState.showSnackBar(SnackBar(
        content: Text('Veuillez enregistrer un message vocal...'),
      ));
      return;
    }

    Messaging _message = Messaging(
      messageType: 'VOICE',
      createdAt: formatDate(DateTime.now(), [dd,'/',mm,'/',yyyy,' à ',HH,':',nn,':',ss]),
      timestamp: DateTime.now().toIso8601String(),
      userId: 'Tipo-Tipo',
      content: "",
      mediaUrl: "",
      district: district,
      province: province,
      cachedUrl: cachedUrl,
      status: 0,
      statusName: 'no_sync',
    );
    // db.sendToServer(_message);
    widget.shouldSendMessage(_message);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void saveMessage() {
    if (cachedUrl == '') {
      _addVoicedKey.currentState.showSnackBar(SnackBar(
        content: Text('Veuillez enregistrer un message vocal'),
      ));
      return;
    }

    Messaging _message = Messaging(
      messageType: 'VOICE',
      createdAt: formatDate(DateTime.now(), [dd,'/',mm,'/',yyyy,' à ',HH,':',nn,':',ss]),
      timestamp: DateTime.now().toIso8601String(),
      userId: 'Tipo-Tipo',
      content: "",
      mediaUrl: "",
      district: district,
      province: province,
      cachedUrl: cachedUrl,
      status: 0,
      statusName: 'no_sync',
    );
    
    db.saveMessage(_message);
    widget.shouldAddList(true);
    Navigator.of(context).pop();
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

  Future _pickFile() async {
    try {
      AudioTrack track = await _stereo.picker();
      setState(() {
        _isFileAttached = true;
        cachedUrl = track.path;
      });      
    } on StereoPermissionsDeniedException catch (_) {
      print('ERROR: Permissions denied');
    } on StereoNoTrackSelectedException {
      print('ERROR: No track selected');
    }
  }

  _start() async {
    try {
      if (await AudioRecorder.hasPermissions) {
        final Directory tempDir = Directory.systemTemp;
        Random random = Random();
        final int randomName = random.nextInt(1000000000);
        final String path = '${tempDir.path}/Record_$randomName';
        await AudioRecorder.start(path: path, audioOutputFormat: AudioOutputFormat.AAC);
        startWatch();
        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _isFileAttached = false;
          cachedUrl = '';
          _recording = Recording(duration: Duration(), path: '');
          _isRecording = isRecording;
        });
      } else {
        _addVoicedKey.currentState.showSnackBar(SnackBar(content: Text('Ne peut pas enregistrer.')));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  _stop() async {
    stopWatch();
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    File file = await File(recording.path);
    setState(() {
      _recording = recording;
      _isRecording = isRecording;
      _isRecorded = true;
      _isFileAttached = true;
      cachedUrl = _recording.path;
    });
  }

  Widget getRecorder() {
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
              title: district.isNotEmpty ? Text(district) : Text('Sélectionner une ville', overflow: TextOverflow.ellipsis, maxLines: 1),
              onTap: () {
                showDialog(context: context, builder: (context) => SelectDistrict(onSelectValues: _onSelectValues,));
              },
            ),
          ),
          SizedBox(height: 16.0,),
          Container(
           child: Text('Enregistrement audio', textAlign: TextAlign.center,), 
          ),
          SizedBox(height: 8.0,),
          _isFileAttached ? Column(
            children: <Widget>[
              getPlayer(),
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
          ) : Column(children: <Widget>[getRecorder()]),
          SizedBox(height: 16.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              resetState() ? FloatingActionButton(
                child: Icon(Icons.replay),
                elevation: 1.0,
                onPressed: () {
                  setState(() {
                    _isFileAttached = false;
                    _isPlaying = false;
                    _isRecorded = false;
                  });
                  resetWatch();
                  stop();
                },
              )
            : (_isRecording
                ? FloatingActionButton(
                    backgroundColor: Colors.red,
                    elevation: 1.0,
                    onPressed: _isRecording ? _stop : null,
                    child: Icon(Icons.stop),
                  )
                : FloatingActionButton(
                    elevation: 1.0,
                    onPressed: _isRecording ? null : _start,
                    child: Icon(Icons.keyboard_voice)
                  )
              ),                
              FloatingActionButton(
                  elevation: 1.0,
                  child: Icon(Icons.attach_file),
                  onPressed: () {
                    _pickFile();
                    setState(() {
                      _isRecording = false;
                      _isPlaying = false;
                    });
                    stop();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _addVoicedKey,
      appBar: AppBar(
        title: Text('Retour'),
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