import 'package:meta/meta.dart';

@immutable
class Result {
  final int moves;
  final int time;
  final int size;

  Result({@required this.moves, @required this.time, @required this.size});
}
