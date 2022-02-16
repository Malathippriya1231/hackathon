import 'dart:math';

import 'package:flutpuz_hack/result/point.dart';
import 'package:flutpuz_hack/platform/serializable.dart';
import 'package:meta/meta.dart';

import 'tile.dart';

@immutable
class Board extends Serializable {
  /// Width and height of a board, for
  /// example 4x4.
  final int size;

  final List<Tile> tiles;

  final Point<int> blank;

  Board(this.size, this.tiles, this.blank);

  factory Board.createNormal(int size) =>
      Board.create(size, (n) => Point(n % size, n ~/ size));

  factory Board.create(int size, Point<int> Function(int) factory) {
    final blank = factory(size * size - 1);
    final tiles = List<Tile>.generate(size * size - 1, (n) {
      final point = factory(n);
      return Tile(n, point, point);
    });
    return Board(size, tiles, blank);
  }

  /// Returns `true` if all of the [tiles] are in their
  /// target positions.
  bool isSolved() {
    for (var tile in tiles) {
      if (tile.targetPoint != tile.currentPoint) return false;
    }
    return true;
  }

  @override
  void serialize(SerializeOutput output) {
    output.writeInt(size);
    output.writeSerializable(PointSerializableWrapper(blank));

    for (final tile in tiles) {
      output.writeSerializable(tile);
    }
  }
}

class BoardDeserializableFactory extends DeserializableHelper<Board> {
  const BoardDeserializableFactory() : super();

  @override
  Board deserialize(SerializeInput input) {
    final size = input.readInt();
    if (size == null) {
      return null;
    }

    const pointFactory = PointDeserializableFactory();
    const tileFactory = TileDeserializableFactory();

    final blank = input.readDeserializable(pointFactory);
    if (blank == null) {
      return null;
    }

    final tiles = List<Tile>();
    final length = size * size - 1;
    for (var i = 0; i < length; i++) {
      final tile = input.readDeserializable(tileFactory);
      if (tile == null) {
        return null;
      }

      tiles.add(tile);
    }

    // TODO: Verify if the loaded data is valid
    return Board(size, tiles, blank);
  }
}
