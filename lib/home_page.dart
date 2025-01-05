import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'const.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late RtcEngine _engine;
  int? _remoteUid;
  bool localUserJoined = false;
  bool isVideoCall = true; // Flag to toggle between audio and video call

  bool startCalling = false;
  bool isSpeaker = true;
  bool isMute = true;
  bool isVideo = true;

  @override
  void initState() {
    getPermission();

    initAgoraEngine();
    super.initState();
  }

  void getPermission() async {
    await [Permission.microphone, Permission.camera].request();
  }

  @override
  void dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: UniqueKey(),
      top: false,
      child: Scaffold(
        backgroundColor: Color(0xFFE8E6E6),
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            if (startCalling)
              IconButton(
                icon: CircleAvatar(
                    child: Icon(
                  isVideoCall ? Icons.call : Icons.videocam,
                  color: Colors.green,
                )),
                onPressed: _toggleCallMode,
              ),
          ],
        ),
        body: startCalling
            ? Stack(
                key: UniqueKey(),
                children: [
                  Center(
                    key: UniqueKey(),
                    child: _remoteVideo(),
                  ),
                  if (isVideoCall)
                    AnimatedPositioned(
                        left: 0,
                        top: 0,
                        duration: Duration(microseconds: 300),
                        child: Container(
                          color: _remoteUid == null
                              ? Colors.transparent
                              : Colors.black12,
                          width: _remoteUid == null
                              ? MediaQuery.of(context).size.width
                              : 100,
                          height: _remoteUid == null
                              ? MediaQuery.of(context).size.height
                              : 150,
                          child: Center(
                            child: localUserJoined && isVideo
                                ? AgoraVideoView(
                                    controller: VideoViewController(
                                      rtcEngine: _engine,
                                      canvas: const VideoCanvas(uid: 0),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: _remoteUid == null ? 70 : 30,
                                        child: Icon(
                                          Icons.person,
                                          size: _remoteUid == null ? 50 : 20,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          'Avtar',
                                          style: TextStyle(
                                              fontSize:
                                                  _remoteUid == null ? 32 : 20),
                                        ),
                                      ),
                                      if (_remoteUid == null)
                                        SizedBox(
                                          height: 150,
                                        ),
                                    ],
                                  ),
                          ),
                        )),
                  if (!isVideoCall)
                    Positioned(
                      left: (MediaQuery.of(context).size.width - 140) / 2,
                      top: 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 70,
                            child: Icon(
                              Icons.person,
                              size: 50,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'Avtar',
                              style: TextStyle(fontSize: 32),
                            ),
                          ),
                          SizedBox(
                            height: 200,
                          ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      color: Colors.black12,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () {
                                  speakerMode();
                                },
                                icon: CircleAvatar(
                                  backgroundColor:
                                      isSpeaker ? Colors.white : Colors.black12,
                                  child: Icon(
                                    isSpeaker
                                        ? Icons.volume_mute_sharp
                                        : Icons.volume_off,
                                  ),
                                )),
                            IconButton(
                                onPressed: () {
                                  voiceMute();
                                },
                                icon: CircleAvatar(
                                  backgroundColor:
                                      isMute ? Colors.white : Colors.black12,
                                  child: Icon(
                                    Icons.keyboard_voice,
                                  ),
                                )),
                            IconButton(
                                onPressed: () {
                                  _videoToggle();
                                },
                                icon: CircleAvatar(
                                  backgroundColor: isVideoCall && isVideo
                                      ? Colors.white
                                      : Colors.black12,
                                  child: Icon(
                                    Icons.videocam,
                                  ),
                                )),
                            IconButton(
                                onPressed: () {
                                  callDisconnect();
                                },
                                icon: CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.call,
                                    color: Colors.white,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MaterialButton(
                        color: Colors.green,
                        onPressed: () {
                          initAgora(isVideoC: false);
                        },
                        child: Icon(
                          Icons.call,
                          color: Colors.white,
                        ),
                      ),
                      MaterialButton(
                        color: Colors.green,
                        onPressed: () {
                          initAgora(isVideoC: true);
                        },
                        child: Icon(
                          Icons.video_call,
                          color: Colors.white,
                        ),
                      )
                    ],
                  )
                ],
              ),
      ),
    );
  }

  Future<void> initAgoraEngine({bool isVideoCall = true}) async {
    if (true) {
      _engine = createAgoraRtcEngine();
      await _engine.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      await _engine.joinChannel(
        token: token,
        channelId: channel,
        options: const ChannelMediaOptions(
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
        uid: 0,
      );
    }

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            localUserJoined = true;
          });
        },
        onUserJoined:
            (RtcConnection connection, int remoteUid, int elapsed) async {
          debugPrint(
              "remote user $remoteUid pagal  ${connection.channelId} ${connection.localUid}joined");
          if (remoteUid != 0) {
            if (!startCalling) {
              await callDialog().then((val) async {
                if (val) {
                  startCalling = true;
                  await _engine.enableVideo(); // Start with video enabled
                  await _engine.startPreview();
                }
              });
              setState(() {
                _remoteUid = remoteUid;
              });
            } else {
              setState(() {
                startCalling = false;
                _remoteUid = remoteUid;
              });
            }
          }
        },
        onRemoteVideoStats:
            (RtcConnection rtcConnection, RemoteVideoStats state) {
          debugPrint("Remote video stats: ${state.uid ?? 0}");
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel 34");
          callDisconnect();
          // initAgoraEngine();
        },
      ),
    );
  }

  Future<bool> callDialog() async {
    final AudioPlayer _audioPlayer =
        AudioPlayer(); // Create an instance of AudioPlayer
    await _audioPlayer.play(AssetSource('audio/ring_tone.mp3'),
        volume: 100); // Replace with the path of your audio file

    final res = await showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          iconPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Incoming Call'),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    icon: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(
                          Icons.call_end,
                          color: Colors.white,
                        ))),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    icon: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.call,
                          color: Colors.white,
                        ))),
              ],
            ),
          ],
        );
      },
    );
    await _audioPlayer.stop();

    return res;
  }

  Future<void> initAgora({required bool isVideoC}) async {
    await _engine.enableVideo(); // Start with video enabled
    await _engine.startPreview();
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            localUserJoined = true;
          });
        },
        onUserJoined:
            (RtcConnection connection, int remoteUid, int elapsed) async {
          debugPrint(
              "remote user $remoteUid   ${connection.channelId} ${connection.localUid}joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onRemoteVideoStats:
            (RtcConnection rtcConnection, RemoteVideoStats state) {
          debugPrint("Remote video stats: ${state.uid ?? 0}");
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel 34");
          callDisconnect();
          // initAgoraEngine();
        },
      ),
    );
    setState(() {
      isVideoCall = isVideoC;
      startCalling = true;
    });
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channel),
        ),
      );
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
      );
    }
  }

  void callDisconnect() async {
    await _engine.leaveChannel();
    // await _engine.release();
    setState(() {
      _remoteUid = null;
      localUserJoined = false;
      startCalling = false;
      isVideoCall = true; // Reset to default call mode
    });
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    await _engine.joinChannel(
      token: token,
      channelId: channel,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );
  }

  void voiceMute() async {
    isMute = !isMute;
    if (isMute) {
      await _engine.enableLocalAudio(false); // Ensure audio is enabled
    } else {
      await _engine.enableLocalAudio(true); // Ensure audio is enabled
    }
    setState(() {});
  }

  void speakerMode() async {
    isSpeaker = !isSpeaker;
    if (isSpeaker) {
      await _engine.setEnableSpeakerphone(true);
    } else {
      await _engine.setEnableSpeakerphone(false);
    }
    setState(() {});
  }

  // Video pause and resume
  void _videoToggle() async {
    if (isVideoCall) {
      isVideo = !isVideo;
    } else {
      isVideoCall = true;
      await _engine.enableVideo();
      await _engine.startPreview();
      isVideo = true;
      await _engine.enableLocalAudio(true);
    }
    setState(() {});
  }

  // Call switch video to audio and vise versa
  void _toggleCallMode() async {
    isVideoCall = !isVideoCall;
    if (isVideoCall) {
      await _engine.enableVideo();
      await _engine.startPreview();
      await _engine.enableLocalAudio(true); // Ensure audio is enabled
    } else {
      await _engine.stopPreview();
      await _engine.disableVideo();
      await _engine.enableLocalAudio(true); // Ensure audio is enabled
    }
    setState(() {});
  }
}
