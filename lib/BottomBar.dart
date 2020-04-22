import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/cupertino_progress_bar.dart';
import 'package:chewie/src/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_iconic_flutter/open_iconic_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:video_app/CustomChewie.dart';
import 'package:video_app/PlayerControl.dart';

class CupertinoBottomBar extends StatefulWidget {
  const CupertinoBottomBar({
      @required this.backgroundColor,
      @required this.iconColor,
      @required this.context,
      @required this.nextVideo,
      @required this.previousVideo,
  });

  final Color backgroundColor;
  final Color iconColor;
  final BuildContext context;
  final void Function() nextVideo;
  final void Function() previousVideo;

  @override
  State<StatefulWidget> createState() {
    return _CupertinoBottomBarState();
  }
}

class _CupertinoBottomBarState extends State<CupertinoBottomBar> {
  VideoPlayerValue _latestValue;
  double _latestVolume;
  bool _hideStuff = true;
  Timer _hideTimer;
  final marginSize = 5.0;
  Timer _expandCollapseTimer;
  Timer _initTimer;

  VideoPlayerController controller;
  ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    chewieController = ChewieController.of(context);

    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder(
              context,
              chewieController.videoPlayerController.value.errorDescription,
            )
          : Center(
              child: Icon(
                OpenIconicIcons.ban,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    final backgroundColor = widget.backgroundColor;
    final iconColor = widget.iconColor;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;
    final orientation = MediaQuery.of(context).orientation;
    final barHeight = 100.0;

    return _buildBottomBar(backgroundColor, iconColor, barHeight);
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _expandCollapseTimer?.cancel();
    _initTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  Widget _buildBottomBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
  ) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 10.0,
            sigmaY: 10.0,
          ),
          child: Container(
              height: 100,
              color: Color.fromRGBO(43,43,43, 1),
              // color: backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width - 50,
                    // color: Colors.orange,
                    height: 50,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildSkipBack(iconColor, barHeight),
                      _buildPlayPause(controller, iconColor, barHeight),
                      _buildSkipForward(iconColor, barHeight),
                    ],
                  ),),

                  Container(
                    width: MediaQuery.of(context).size.width - 100,
                    // color: Colors.greenAccent,
                    height: 50,
                    child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildPosition(iconColor),
                      _buildProgressBar(),
                      _buildRemaining(iconColor)
                    ],
                  ),)
                  
                 
                ],
              )),
        ),
      
    );
  }

  GestureDetector _buildPlayPause(
    VideoPlayerController controller,
    Color iconColor,
    double barHeight,
  ) {
    final orientation = MediaQuery.of(context).orientation;
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: EdgeInsets.only(
          left: 10.0,
          right: 10.0,
        ),
        child: Icon(
          controller.value.isPlaying
              ? OpenIconicIcons.mediaPause
              : OpenIconicIcons.mediaPlay,
          color: iconColor,
          size: orientation == Orientation.portrait ? 30.0 : 25.0,
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor) {
    final position =
        _latestValue != null ? _latestValue.position : Duration(seconds: 0);

    return Padding(
      padding: EdgeInsets.only(right: 12.0, left: 12.0),
      child: Text(
        formatDuration(position),
        style: TextStyle(
          color: iconColor,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildRemaining(Color iconColor) {
    final position = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration - _latestValue.position
        : Duration(seconds: 0);

    return Padding(
      padding: EdgeInsets.only(right: 12.0),
      child: Text(
        '-${formatDuration(position)}',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    final orientation = MediaQuery.of(context).orientation;
    return GestureDetector(
      onTap: () {
        widget.previousVideo();
      },
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: EdgeInsets.only(left: 10.0),
        padding: EdgeInsets.only(
          left: orientation == Orientation.portrait ? 6.0 : 12.0,
          right: orientation == Orientation.portrait ? 6.0 : 12.0,
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewY(0.0)
            ..rotateX(math.pi)
            ..rotateZ(math.pi),
          child: Icon(
            OpenIconicIcons.mediaStepForward,
            color: iconColor,
            size: orientation == Orientation.portrait ? 20.0 : 25.0,
          ),
        ),
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    final orientation = MediaQuery.of(context).orientation;
    return GestureDetector(
      onTap: () {
        widget.nextVideo();
      },
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: EdgeInsets.only(
          left: orientation == Orientation.portrait ? 6.0 : 12.0,
          right: orientation == Orientation.portrait ? 6.0 : 12.0,
        ),
        margin: EdgeInsets.only(
          right: 8.0,
        ),
        child: Icon(
          OpenIconicIcons.mediaStepForward,
          color: iconColor,
          size: orientation == Orientation.portrait ? 20.0 : 25.0,
        ),
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();

    setState(() {
      _hideStuff = false;

      _startHideTimer();
    });
  }

  Future<Null> _initialize() async {
    controller.addListener(_updateState);

    _updateState();

    if ((controller.value != null && controller.value.isPlaying) ||
        chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      chewieController.toggleFullScreen();
      _expandCollapseTimer = Timer(Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: 12.0),
        child: CupertinoVideoProgressBar(
          controller,
          onDragStart: () {
            _hideTimer?.cancel();
          },
          onDragEnd: () {
            _startHideTimer();
          },
          colors:
              // chewieController.cupertinoProgressColors ??
              ChewieProgressColors(
            playedColor: Color.fromRGBO(
              50,82,179,
              1
              // 120,
              // 255,
              // 255,
              // 255,
            ),
            handleColor: Color.fromRGBO(
              0,255,127,1
              // 255,
              // 255,
              // 255,
              // 255,
            ),
            bufferedColor: Color.fromARGB(
              60,
              255,
              255,
              255,
            ),
            backgroundColor: Color.fromARGB(
              20,
              255,
              255,
              255,
            ),
          ),
        ),
      ),
    );
  }

  void _playPause() {
    bool isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration(seconds: 0));
          }
          controller.play();
        }
      }
    });
  }

  void _skipBack() {
    _cancelAndRestartTimer();
    final beginning = Duration(seconds: 0).inMilliseconds;
    final skip = (_latestValue.position - Duration(seconds: 15)).inMilliseconds;
    controller.seekTo(Duration(milliseconds: math.max(skip, beginning)));
  }

  void _skipForward() {
    _cancelAndRestartTimer();
    final end = _latestValue.duration.inMilliseconds;
    final skip = (_latestValue.position + Duration(seconds: 15)).inMilliseconds;
    controller.seekTo(Duration(milliseconds: math.min(skip, end)));
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _startHideTimerNow() {
    _hideTimer = Timer(const Duration(microseconds: 500), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _updateState() {
    setState(() {
      _latestValue = controller.value;
    });
  }
}