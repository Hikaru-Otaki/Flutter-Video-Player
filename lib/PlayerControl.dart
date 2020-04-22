import 'dart:ui' as ui;

// import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/cupertino_controls.dart';
import 'package:chewie/src/material_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_app/CustomChewie.dart';

class CustomPlayerWithControls extends StatelessWidget {
  CustomPlayerWithControls({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChewieController chewieController = ChewieController.of(context);
    final orientation = MediaQuery.of(context).orientation;

    return Container(
        child: orientation == Orientation.portrait
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () { Navigator.of(context).pop(); },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10.0),
                          child: Container(
                            height: 40,
                            width: 50,
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            color: Color.fromRGBO(41, 41, 41, 0.7),
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Color.fromARGB(255, 200, 200, 200),
                                size: 18.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 80,
                  ),

                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: AspectRatio(
                        aspectRatio: chewieController.aspectRatio ??
                            _calculateAspectRatio(context),
                        child:
                            _buildPlayerWithControls(chewieController, context),
                      ),
                    ),
                  ),

                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          padding: EdgeInsets.only(top: 80),
                          // color: Colors.blue,
                          child:
                              _customBuildControls(context, chewieController))),

                  // IconButton(color: Colors.yellow, icon: Icon(Icons.arrow_back), iconSize: 15, onPressed: () {},),
                ],
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                child: AspectRatio(
                  aspectRatio: chewieController.aspectRatio ??
                      _calculateAspectRatio(context),
                  child: _buildPlayerWithControls(chewieController, context),
                ),
              ));
  }

  Container _buildPlayerWithControls(
      ChewieController chewieController, BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          chewieController.placeholder ?? Container(),
          Center(
            child: AspectRatio(
              aspectRatio: chewieController.aspectRatio ??
                  _calculateAspectRatio(context),
              child: VideoPlayer(chewieController.videoPlayerController),
            ),
          ),
          chewieController.overlay ?? Container(),
          _buildControls(context, chewieController),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    ChewieController chewieController,
  ) {
    return chewieController.showControls
        ? chewieController.customControls != null
            ? chewieController.customControls
            : Theme.of(context).platform == TargetPlatform.android
                ? MaterialControls()
                : CupertinoControls(
                    backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
                    iconColor: Color.fromARGB(255, 200, 200, 200),
                  )
        : Container();
  }

  Widget _customBuildControls(
    BuildContext context,
    ChewieController chewieController,
  ) {
    return chewieController.customBottomBar != null
        ? chewieController.customBottomBar
        : Container();
  }

  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }
}
