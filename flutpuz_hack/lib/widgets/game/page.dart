import 'package:flutpuz_hack/result/output.dart';
import 'package:flutpuz_hack/widgets/game/puzzle/page.dart';
import 'package:flutpuz_hack/widgets/game/puzzle/conquer.dart';
import 'package:flutpuz_hack/widgets/game/presenter/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rootWidget = _buildRoot(context);
    return GamePresenterWidget(
      child: rootWidget,
      onSolve: (result) {
        _showVictoryDialog(context, result);
      },
    );
  }

  Widget _buildRoot(BuildContext context) {
    return GameMaterialPage();
  }

  void _showVictoryDialog(BuildContext context, Result result) {
    showDialog(
      context: context,
      builder: (context) => GameVictoryDialog(result: result),
    );
  }


}
