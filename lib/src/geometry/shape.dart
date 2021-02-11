import 'dart:ui';

import '../../components.dart';
import '../extensions/vector2.dart';
import 'shape_intersections.dart' as intersection_system;

abstract class Shape {
  Vector2 position = Vector2.zero();
  Vector2 size;
  double angle;

  Vector2 get shapeCenter => position;
  Vector2 get anchorPosition => position;

  Shape({
    this.position,
    this.size,
    this.angle = 0,
  }) {
    position ??= Vector2.zero();
  }

  bool containsPoint(Vector2 p);

  void render(Canvas c, Paint paint);

  /// Where this Shape has intersection points with another shape
  Set<Vector2> intersections(Shape other) {
    return intersection_system.intersections(this, other);
  }
}

mixin HitboxShape on Shape {
  PositionComponent component;

  @override
  Vector2 get anchorPosition => component.absolutePosition;

  @override
  Vector2 get size => component.size;

  @override
  double get angle => component.angle;

  @override

  /// The shapes center, before rotation
  Vector2 get shapeCenter {
    return component.absoluteCenter + position;
  }

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape collides with another [HitboxShape]
  CollisionCallback collisionCallback = emptyCollisionCallback;
}

typedef CollisionCallback = Function(Set<Vector2> points, HitboxShape other);
final CollisionCallback emptyCollisionCallback = (_a, _b) {};

/// Used for caching calculated shapes, the cache is determined to be valid by
/// comparing a list of values that can be of any type and is compared to the
/// values that was last used when the cache was updated.
class ShapeCache<T> {
  T value;

  List<dynamic> _lastValidCacheValues = <dynamic>[];

  ShapeCache();

  bool isCacheValid(List<dynamic> validCacheValues) {
    for (int i = 0; i < _lastValidCacheValues.length; ++i) {
      if (_lastValidCacheValues[i] != validCacheValues[i]) {
        return false;
      }
    }
    return value != null;
  }

  T updateCache(T update(), List<dynamic> validCacheValues) {
    value = update();
    _lastValidCacheValues = validCacheValues;
    return value;
  }
}
