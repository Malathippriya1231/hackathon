import 'dart:math';

import 'package:flutpuz_hack/platform/serializable.dart';
import 'package:meta/meta.dart';

import 'point.dart';

@immutable
class Tile implements Serializable {
  /// Unique identifier of a tile, starts
  /// from a zero.
  final int number;

  final Point<int> targetPoint;

  final Point<int> currentPoint;

  const Tile(
    this.number,
    this.targetPoint,
    this.currentPoint,
  );

  Tile move(Point<int> point) => Tile(number, targetPoint, point);

  @override
  void serialize(SerializeOutput output) {
    output.writeInt(number);
    output.writeSerializable(PointSerializableWrapper(targetPoint));
    output.writeSerializable(PointSerializableWrapper(currentPoint));
  }
}

class TileDeserializableFactory extends DeserializableHelper<Tile> {
  const TileDeserializableFactory() : super();

  @override
  Tile deserialize(SerializeInput input) {
    final pd = PointDeserializableFactory();

    final number = input.readInt();
    final targetPoint = input.readDeserializable(pd);
    final currentPoint = input.readDeserializable(pd);
    return Tile(number, targetPoint, currentPoint);
  }
}
