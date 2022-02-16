import 'package:flutpuz_hack/result/output.dart';
import 'package:flutpuz_hack/widgets/game/clock.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:easy_gradient_text/easy_gradient_text.dart';
import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';
class GameVictoryDialog extends StatelessWidget {
  final Result result;

  final String Function(int) timeFormatter;

  GameVictoryDialog({
    @required this.result,
    this.timeFormatter: formatElapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    AssetsAudioPlayer.newPlayer().seek(const Duration(milliseconds: 50));
    AssetsAudioPlayer.newPlayer().open(
      Audio("audios/win.mp3"),
      autoStart: true,
    );
    final timeFormatted = timeFormatter(result.time);
    final actions = <Widget>[
     ConfettiView(),
    new FlatButton(
        child: new Text("Close", style: TextStyle(
          fontSize: 25.0,)),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ];

     return AlertDialog(
      title: Center(
        child: GradientText(
          text: 'Hurray!!',
          colors: <Color>[
            Colors.pink,
            Colors.lightBlueAccent
          ],
          style: TextStyle(fontSize: 40.0,
          letterSpacing: 3),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
              "You've conquered the ${result.size}x${result.size} puzzle in Flutpuz",
              style: TextStyle(
        fontSize: 25.0,)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Time:',
                    style: TextStyle(fontSize:25,color: Colors.pink),
                  ),
                  Text(
                    timeFormatted,
                    style: TextStyle(fontSize:23,color: Colors.cyan),
                  ),
                ],
              ),
            Column( crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[ Container(
                child:Image.asset('images/trophy.png',height:50,width: 50,),
              ),]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Moves:',
                    style: TextStyle(
                        fontSize:25,color: Colors.pink),
                  ),
                  Text(
                    '${result.moves}',
                    style: TextStyle(fontSize:23,color: Colors.cyan),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: actions,
    );
  }
}

class ConfettiView extends StatefulWidget {
  @override
  _ConfettiViewState createState() => _ConfettiViewState();
}

class _ConfettiViewState extends State<ConfettiView> {
  ConfettiController _controller;

  @override
  void initState() {
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play(); // <-- This causes the confetti to get stuck in one location and flash (when in a showModalBottomSheet)
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration:BoxDecoration(
          color: Colors.transparent
      ),
      child:
      Align(
        alignment: Alignment.center,
        child: ConfettiWidget(
          confettiController: _controller,
          blastDirection:-pi / 2,
          blastDirectionality: BlastDirectionality.directional,
          colors: const [
            Colors.lightGreen,
            Colors.lightBlueAccent,
            Colors.pink,
            Colors.orange,
            Colors.purple,
            Colors.yellowAccent
          ],
        ),
      ),
    );
  }
}
