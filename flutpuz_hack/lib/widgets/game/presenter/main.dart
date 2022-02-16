import 'dart:convert';
import 'dart:math';

import 'package:flutpuz_hack/result/box.dart';
import 'package:flutpuz_hack/result/output.dart';
import 'package:flutpuz_hack/position/positions.dart';
import 'package:flutpuz_hack/platform/serializable.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamePresenterWidget extends StatefulWidget {
  static const SUPPORTED_SIZES = [3, 4, 5];

  final Widget child;

  final Function(Result) onSolve;

  GamePresenterWidget({@required this.child, this.onSolve});

  static GamePresenterWidgetState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()
        .data;
  }

  @override
  GamePresenterWidgetState createState() => GamePresenterWidgetState();
}

class GamePresenterWidgetState extends State<GamePresenterWidget>
    with WidgetsBindingObserver {
  static const TIME_STOPPED = 0;

  final Game game = Game.instance;

  Board board;

  int moves;

  int time;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    board = null;
    moves = null;
    time = TIME_STOPPED;

    _loadState();
  }

  void _loadState() async {
    dynamic jsonMap;

    int elapsedTime;
    int time;
    int steps;
    Board board;

    try {
      final deserializer = MapSerializeInput(map: jsonMap);
      const boardFactory = BoardDeserializableFactory();
      elapsedTime = deserializer.readInt();
      time = deserializer.readInt();
      steps = deserializer.readInt();
      board = deserializer.readDeserializable(boardFactory);
    } catch (Exception) {}

    final now = DateTime.now().millisecondsSinceEpoch;
    if ( // validate time
        time == null ||
            time < 0 ||
            time > now ||
            time > 0 && elapsedTime > now - time ||
            // validate steps
            steps == null ||
            steps < 0 ||
            // validate board
            board == null) {
      time = TIME_STOPPED;
      steps = 0;
      // Initialize empty board with a classic
      // pattern.
      const size = 4;
      board = _createBoard(size);
    }

    setState(() {
      this.time = time;
      this.moves = steps;
      this.board = board;
    });
  }

  Board _createBoard(int size) => Board.createNormal(size);

  void playStop() {
    if (isPlaying()) {
      stop();
    } else {
      play();
    }
  }

  void play() {
    assert(board != null);

    final now = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      time = now;
      moves = 0;
      board =
          game.shuffle(game.hardest(board), amount: board.size * board.size);
    });
  }

  void stop() {
    setState(() {
      time = TIME_STOPPED;
      moves = 0;
    });
  }

  bool isPlaying() => time != TIME_STOPPED;

  void resize(int size) {
    setState(() {
      time = TIME_STOPPED;
      moves = 0;
      board = _createBoard(size);
    });
  }

  void tap({@required Point<int> point}) {
    assert(board != null);
    assert(point != null);

    setState(() {
      board = game.tap(board, point: point);

      if (isPlaying()) {
        // Increment the amount of steps.
        moves = moves + 1;

        // Stop if a user has solved the
        // board.
        if (board.isSolved()) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final result = Result(
            moves: moves,
            time: now - time,
            size: board.size,
          );

          widget.onSolve?.call(result);

          stop();
        }
      }
    });
  }

  /// Resets the board, keeping the `isPlaying` state
  /// the same.
  void reset() {
    setState(() {
      int timeFuture;
      if (isPlaying()) {
        final now = DateTime.now().millisecondsSinceEpoch;
        timeFuture = now;
      } else {
        timeFuture = TIME_STOPPED;
      }

      var boardFuture;
      if (isPlaying()) {
        boardFuture =
            game.shuffle(game.hardest(board), amount: board.size * board.size);
      } else {
        boardFuture = _createBoard(board.size);
      }

      time = timeFuture;
      moves = 0;
      board = boardFuture;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        try {
          _saveState();
        } on Exception {}
        break;
      default:
        break;
    }
  }

  void _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final serializer = MapSerializeOutput();



    // Write the delta of time, so user can not close the app, change
    // time and go back so easily.
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedTime = now - time;

    serializer.writeInt(elapsedTime);
    serializer.writeInt(time);
    serializer.writeInt(moves);
    serializer.writeSerializable(board);

    final plainText = serializer.toJsonString();
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final GamePresenterWidgetState data;

  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
