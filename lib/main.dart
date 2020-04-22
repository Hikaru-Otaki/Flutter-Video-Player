import 'package:video_app/BottomBar.dart';
// import 'package:video_app/CustomControl.dart';
// import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_app/CustomChewie.dart';

void main() {
  runApp(
    ChewieVideo(),
  );
}

class ChewieVideo extends StatefulWidget {
  ChewieVideo({this.videoList, Key key}) : super(key: key);

  final List<String> videoList;

  @override
  _ChewieVideoState createState() {
    return _ChewieVideoState(urls: videoList);
  }
}

class _ChewieVideoState extends State<ChewieVideo> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _ChewieVideoState({@required List<String> urls}) : this.urls = urls;

  VoidCallback _listener;
  int index = 0;
  bool _isLoading = false;
  bool _changeLock = false;
  // bool _occuringError = false;
  List<ChewieController> _controllers = [];
  VideoPlayerController videoPlayerController;
  List<String> urls;
  

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose');
    _controllers.forEach((element) {
      if (element is ChewieController) {
        element.pause().then((_) {
          element.videoPlayerController.dispose().then((_) {
            element.dispose();
          });
        });
      }
    });
    debugPrint('CmVideoPlayer - dispose()');
  }

  _initControllers() async {
    _controllers.add(null);
    for (int i = 0; i < urls.length; i++) {
      if (i == 2) {
        break;
      }
      _controllers.add(ChewieController(
        customBottomBar: CupertinoBottomBar(
            nextVideo: nextVideo,
            previousVideo: previousVideo,
            backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
            iconColor: Color.fromARGB(255, 200, 200, 200),
            context: context),
        aspectRatio: 16 / 9,
        autoPlay: false,
        allowFullScreen: false,
        videoPlayerController: VideoPlayerController.network(urls[i]),
      ));
    }

    await attachListenerAndInit(_controllers[1]).then((_) {
      _controllers[1].play().then((_) {
        print('first play');
        if (mounted) {
          setState(() {
            _changeLock = false;
          });
        } else {
          print('not mounted');
        }
      });
    }).catchError((e) {
      print('######ERROR#####' + e);
    });

    if (_controllers.length > 2) {
      attachListenerAndInit(_controllers[2]);
    }
  }

  Future<void> attachListenerAndInit(ChewieController controller) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    } else {
      print('not mounted');
    }

    if (!controller.videoPlayerController.hasListeners) {
      _listener = () {
        Duration dur = controller.videoPlayerController.value.duration;
        Duration pos = controller.videoPlayerController.value.position;

        if (dur == pos) {
          if (controller.isFullScreen) {
            controller.exitFullScreen();
          }

          if (index == urls.length - 1) {
            controller.pause().then((_) {
              // controller.removeListener(_listener);
              _showVideoDoneDialog('お疲れ様です。');
            });
            return;
          } else {
            print('next video');
            controller.seekTo(Duration(milliseconds: 0));
            nextVideo();
          }
        }
      };
      controller.videoPlayerController.addListener(_listener);
    }

    controller.videoPlayerController.initialize().then((_) {
      print('initialized');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _changeLock = false;
        });
      } else {
        print('not mounted');
      }
    }).catchError((e) {
      print('initialized error' + e);
      if (mounted) {
        setState(() {
          // _occuringError = true;
          _changeLock = false;
          // _isLoading = false;
        });
      } else {
        print('not mounted');
      }

      controller.pause()?.then((_) {
        // controller.removeListener(_listener);
        // controller.dispose();
      });
    });
  }

  void _showVideoDoneDialog(String text) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(hours: 1),
        action: SnackBarAction(
          label: '完了',
          onPressed: () {
            print('DONE');
            // _occuringError = false;
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void previousVideo() async {
    print('previous');
    if (_changeLock) {
      return;
    }
    _changeLock = true;

    if (index == 0) {
      print('もうこれ以上戻れないよ');
      _changeLock = false;
      _isLoading = false;
      return;
    }
    _controllers[1]?.pause();
    index--;

    if (index != urls.length - 2) {
      // _controllers.last?.removeListener(_listener);
      // _controllers.last.videoPlayerController.dispose().then((value) {
      _controllers.last?.dispose();
      _controllers.removeLast();
      // });
    }
    if (index != 0) {
      _controllers.insert(
          0,
          ChewieController(
            customBottomBar: CupertinoBottomBar(
                nextVideo: nextVideo,
                previousVideo: previousVideo,
                backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
                iconColor: Color.fromARGB(255, 200, 200, 200),
                context: context),
            aspectRatio: 16 / 9,
            autoPlay: false,
            allowFullScreen: false,
            videoPlayerController:
                VideoPlayerController.network(urls[index - 1]),
          ));

      await attachListenerAndInit(_controllers.first);
    } else {
      _controllers.insert(0, null);
    }

    _controllers[1].play().then((_) {
      setState(() {
        _changeLock = false;
        _isLoading = false;
      });
    });
  }

  Future<void> nextVideo() async {
    setState(() {
      _isLoading = true;
    });
    print('next');
    if (_changeLock) {
      print('change lock');
      return;
    }
    _changeLock = true;
    if (index == urls.length - 1) {
      print('もうこれ以上進めないよ');
      _changeLock = false;
      _isLoading = false;
      return;
    }

    await _controllers[1]
        .pause()
        .then((value) => print('pause'))
        .catchError((e) => print(e));
    index++;

    if (_controllers.first is ChewieController) {
      await _controllers.first.videoPlayerController.dispose();
      _controllers.first.dispose();
      _controllers.removeAt(0);
    } else {
      _controllers.removeAt(0);
    }

    if (index != urls.length - 1) {
      _controllers.add(
        ChewieController(
          customBottomBar: CupertinoBottomBar(
              nextVideo: nextVideo,
              previousVideo: previousVideo,
              backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
              iconColor: Color.fromARGB(255, 200, 200, 200),
              context: context),
          aspectRatio: 16 / 9,
          autoPlay: false,
          allowFullScreen: false,
          videoPlayerController: VideoPlayerController.network(urls[index]),
        ),
      );

      await attachListenerAndInit(_controllers.last);
    }

    await _controllers[1].videoPlayerController.initialize();
    _controllers[1].play().then((_) {
      // print(_controllers[1].videoPlayerController.dataSource);
      print('nextvideo and play');
      setState(() {
        _changeLock = false;
        _isLoading = false;
      });
    }).catchError((onError) {
      print('PLAY ERROR');
    });
  }

  void pop() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          color: Colors.black,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : OrientationBuilder(
                  builder: (BuildContext context, Orientation orientation) {
                    return orientation == Orientation.portrait
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Chewie(controller: _controllers[1]),
                            ],
                          )
                        : Chewie(controller: _controllers[1]);
                  },
                ),
        ),
      ),
    );
  }
}
