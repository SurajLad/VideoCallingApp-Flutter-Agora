import 'dart:async';
import 'dart:io';
import 'package:chat_app/utils/utils.dart';
import 'package:chat_app/features/home_page.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';

import '../../components/action_widget.dart';
import 'controller/call_controller.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;

  VideoCallScreen({
    required this.channelName,
  });

  @override
  VideoCallScreenState createState() => VideoCallScreenState();
}

class VideoCallScreenState extends State<VideoCallScreen> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  late final AgoraController agoraController;

  // UserJoined Bool
  bool isSomeOneJoinedCall = false;

  int networkQuality = 3;
  Color networkQualityBarColor = Colors.green;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() async {
    print("\n============ ON DISPOSE ===============\n");
    super.dispose();

    agoraController.meetingTimer.cancel();

    // clear users
    _users.clear();

    // destroy Agora sdk
    await agoraController.engine.leaveChannel();
    await agoraController.engine.release();
  }

  @override
  void initState() {
    agoraController = Get.put(AgoraController(channel: widget.channelName));

    // initialize agora sdk
    // initAgoraRTC();

    super.initState();
  }

  // Future<void> initAgoraRTC() async {
  //   if (getAgoraAppId().isEmpty) {
  //     Get.snackbar("", "Agora APP_ID Is Not Valid");
  //     return;
  //   }

  //   await _initAgoraRtcEngine();
  //   // _addAgoraEventHandlers();
  //   await agoraController.engine.enableWebSdkInteroperability(true);

  //   // await agoraController.engine.setParameters(
  //   //   '''{\"che.video.lowBitRateStreamParameter\":{\"width\":640,\"height\":360,\"frameRate\":30,\"bitRate\":800}}''',
  //   // );
  //   await agoraController.engine.joinChannel(
  //     token: 's',
  //     channelId: widget.channelName,
  //     uid: 0,
  //     options: ChannelMediaOptions(),
  //   );

  //   // await agoraController.engine.joinChannel(null, widget.channelName, null, 0);
  // }

  Future<void> _initAgoraRtcEngine() async {
    await agoraController.engine.initialize(RtcEngineContext(
      appId: getAgoraAppId(),
    ));
    await agoraController.engine.enableVideo();
    await agoraController.engine.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 30,
        bitrate: 800,
      ),
    );
  }

  /// agora event handlers
  // void _addAgoraEventHandlers() {
  //   agoraController.engine.registerEventHandler(
  //     RtcEngineEventHandler(
  //       onError: (err, msg) {
  //         print("======== AGORA ERROR  : ======= " + err.toString());
  //         setState(() {
  //           final info = 'onError: $err';
  //           _infoStrings.add(info);
  //         });
  //       },
  //       onUserOffline: (connection, remoteUid, reason) {
  //         setState(() {
  //           final info = 'userOffline: $remoteUid';
  //           _infoStrings.add(info);
  //           _users.remove(remoteUid);
  //         });
  //       },
  //       onJoinChannelSuccess: (connection, elapsed) {
  //         setState(() {
  //           final info = 'onJoinChannel: ${connection.channelId}';
  //           _infoStrings.add(info);
  //         });
  //       },
  //       onLeaveChannel: (connection, stats) {
  //         setState(() {
  //           _infoStrings.add('onLeaveChannel');
  //           _users.clear();
  //         });
  //       },
  //       onUserJoined: (connection, remoteUid, elapsed) {
  //         print("======================================");
  //         print("             User Joined              ");
  //         print("======================================");
  //         if (agoraController.meetingTimer != null) {
  //           if (!agoraController.meetingTimer.isActive) {
  //             agoraController.startMeetingTimer();
  //           }
  //         } else {
  //           agoraController.startMeetingTimer();
  //         }

  //         isSomeOneJoinedCall = true;

  //         setState(() {
  //           final info = 'userJoined: $remoteUid';
  //           _infoStrings.add(info);
  //           _users.add(remoteUid);
  //         });
  //       },
  //       onNetworkQuality: (connection, remoteUid, txQuality, rxQuality) {
  //         setState(() {
  //           networkQuality = getNetworkQuality(txQuality.index);
  //           networkQualityBarColor = getNetworkQualityBarColor(txQuality.index);
  //         });
  //       },
  //       onFirstRemoteVideoFrame:
  //           (connection, remoteUid, width, height, elapsed) {
  //         setState(() {
  //           final info = 'firstRemoteVideo: $remoteUid ${width}x $height';
  //           _infoStrings.add(info);
  //         });
  //       },
  //     ),
  //   );
  // }

  List<Widget> _getRenderViews() {
    return [];
    // final List<AgoraRenderWidget> list = [
    //   AgoraRenderWidget(0, local: true, preview: true),
    // ];
    // _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    // return list;
  }

  Widget _videoView(view) {
    return Expanded(
      child: Container(child: view),
    );
  }

  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  Widget buildJoinUserUI() {
    final views = _getRenderViews();

    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return new Container(
            width: Get.width,
            height: Get.height,
            child: new Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: <Widget>[
                      _expandedVideoRow([views[1]]),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 8,
                            color: Colors.white38,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.fromLTRB(15, 40, 10, 15),
                        width: 110,
                        height: 140,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _expandedVideoRow([views[0]]),
                          ],
                        )))
              ],
            ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  void onCallEnd(BuildContext context) async {
    if (agoraController.meetingTimer != null) {
      if (agoraController.meetingTimer.isActive) {
        agoraController.meetingTimer.cancel();
      }
    }

    if (isSomeOneJoinedCall) {
      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text("Note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "No one has not joined this call yet,\nDo You want to close this room?"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExampleActionsWidget(
      displayContentBuilder: (context, isLayoutHorizontal) {
        if (!agoraController.isPreviewReady.value) return Container();
        return Stack(
          children: [
            AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: agoraController.engine,
                canvas: const VideoCanvas(uid: 0),
                useFlutterTexture: agoraController.isUseFlutterTexture,
                useAndroidSurfaceView: agoraController.isUseAndroidSurfaceView,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.of(agoraController.remoteUid.map(
                    (e) => SizedBox(
                      width: 120,
                      height: 120,
                      child: AgoraVideoView(
                        controller: VideoViewController.remote(
                          rtcEngine: agoraController.engine,
                          canvas: VideoCanvas(uid: e),
                          connection:
                              RtcConnection(channelId: widget.channelName),
                          useFlutterTexture:
                              agoraController.isUseFlutterTexture,
                          useAndroidSurfaceView:
                              agoraController.isUseAndroidSurfaceView,
                        ),
                      ),
                    ),
                  )),
                ),
              ),
            )
          ],
        );
      },
      actionsBuilder: (context, isLayoutHorizontal) {
        final channelProfileType = [
          ChannelProfileType.channelProfileLiveBroadcasting,
          ChannelProfileType.channelProfileCommunication,
        ];
        final items = channelProfileType
            .map((e) => DropdownMenuItem(
                  child: Text(
                    e.toString().split('.')[1],
                  ),
                  value: e,
                ))
            .toList();

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(hintText: 'Channel ID'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (Platform.isIOS)
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Rendered by Flutter texture: '),
                        Switch(
                          value: agoraController.isUseFlutterTexture,
                          onChanged: isJoined
                              ? null
                              : (changed) {
                                  setState(() {
                                    agoraController.isUseFlutterTexture =
                                        changed;
                                  });
                                },
                        )
                      ]),
                if (Platform.isAndroid)
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Rendered by Android SurfaceView: '),
                        Switch(
                          value: agoraController.isUseAndroidSurfaceView,
                          onChanged: isJoined
                              ? null
                              : (changed) {
                                  setState(() {
                                    agoraController.isUseAndroidSurfaceView =
                                        changed;
                                  });
                                },
                        ),
                      ]),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Channel Profile: '),
            DropdownButton<ChannelProfileType>(
              items: items,
              value: _channelProfileType,
              onChanged: isJoined
                  ? null
                  : (v) {
                      setState(() {
                        _channelProfileType = v!;
                      });
                    },
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: isJoined ? _leaveChannel : _joinChannel,
                    child: Text('${isJoined ? 'Leave' : 'Join'} channel'),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: agoraController.onSwitchCamera,
              child: Text(
                  'Camera ${agoraController.backCamera ? 'front' : 'rear'}'),
            ),
          ],
        );
      },
    );
    // return WillPopScope(
    //   onWillPop: () async {
    //     return false;
    //   },
    //   child: Scaffold(
    //     body: buildNormalVideoUI(),
    //     bottomNavigationBar: GetBuilder<AgoraController>(builder: (_) {
    //       return ConvexAppBar(
    //         style: TabStyle.fixedCircle,
    //         backgroundColor: const Color(0xFF1A1E78),
    //         color: Colors.white,
    //         items: [
    //           TabItem(
    //             icon: _.muted ? Icons.mic_off_outlined : Icons.mic_outlined,
    //           ),
    //           TabItem(
    //             icon: Icons.call_end_rounded,
    //           ),
    //           TabItem(
    //             icon: _.muteVideo
    //                 ? Icons.videocam_off_outlined
    //                 : Icons.videocam_outlined,
    //           ),
    //         ],
    //         initialActiveIndex: 2, //optional, default as 0
    //         onTap: (int i) {
    //           switch (i) {
    //             case 0:
    //               _.onToggleMuteAudio();
    //               break;
    //             case 1:
    //               onCallEnd(context);
    //               break;
    //             case 2:
    //               _.onToggleMuteVideo();
    //               break;
    //           }
    //         },
    //       );
    //     }),
    //   ),
    // );
  }

  Widget buildNormalVideoUI() {
    return Container(
      height: Get.height,
      child: Stack(
        children: <Widget>[
          buildJoinUserUI(),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 10, top: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  backgroundColor: Colors.white38,
                  // minWidth: 40,
                  // height: 50,
                ),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                },
                child: Icon(
                  Icons.arrow_back_outlined,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: const EdgeInsets.only(top: 0, left: 10, bottom: 10),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(6)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SignalStrengthIndicator.bars(
                    value: networkQuality,
                    size: 18,
                    barCount: 4,
                    spacing: 0.3,
                    maxValue: 4,
                    activeColor: networkQualityBarColor,
                    inactiveColor: Colors.white,
                    radius: Radius.circular(8),
                    minValue: 0,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Obx(() {
                    return Text(
                      agoraController.meetingDurationTxt.value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(1.0, 2.0),
                            blurRadius: 2.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: GetBuilder<AgoraController>(builder: (_) {
                return Container(
                  margin: const EdgeInsets.only(right: 10, bottom: 4),
                  child: RawMaterialButton(
                    onPressed: _.onSwitchCamera,
                    child: Icon(
                      _.backCamera ? Icons.camera_rear : Icons.camera_front,
                      color: Colors.white,
                      size: 24.0,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    fillColor: Colors.white38,
                  ),
                );
              })),
        ],
      ),
    );
  }

  void addLogToList(String info) {
    print(info);
    setState(() {
      _infoStrings.insert(0, info);
    });
  }
}
