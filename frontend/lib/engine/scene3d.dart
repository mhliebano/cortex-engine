import 'package:vector_math/vector_math_64.dart';
import 'package:cortex/engine/context3d.dart';

/// Maneja la posición, rotación y escala de un objeto en el espacio 3D.
class Transform3D {
  final Vector3 position = Vector3.zero();
  final Vector3 rotation = Vector3.zero(); // x, y, z en radianes
  final Vector3 scale = Vector3.all(1.0);

  final Matrix4 _localMatrix = Matrix4.identity();
  final Matrix4 _worldMatrix = Matrix4.identity();
  bool _dirty = true;

  /// Marca la transformación para ser recalculada.
  void setDirty() => _dirty = true;

  /// Actualiza las matrices local y global (si hay padre).
  void update(Transform3D? parentTransform) {
    if (_dirty || (parentTransform != null && parentTransform._dirty)) {
      _localMatrix.setFromTranslationRotationScale(
        position,
        Quaternion.euler(rotation.z, rotation.y, rotation.x),
        scale
      );

      if (parentTransform != null) {
        _worldMatrix.setFrom(parentTransform._worldMatrix);
        _worldMatrix.multiply(_localMatrix);
      } else {
        _worldMatrix.setFrom(_localMatrix);
      }
      _dirty = false;
    }
  }

  /// Matriz 4x4 global en flat list (column-major) para enviarla al FFI (Raylib).
  List<double> get worldMatrixFloats => _worldMatrix.storage;
  Matrix4 get worldMatrix => _worldMatrix;
  
  /// Extrae la posición global actual de la matriz de mundo.
  Vector3 get worldPosition => _worldMatrix.getTranslation();
}

/// Nodo base para una jerarquía de escena 3D.
class Node3D {
  String name;
  Node3D? _parent;
  final List<Node3D> _children = [];
  final Transform3D transform = Transform3D();

  Node3D({this.name = 'Node3D'});

  /// Añade un nodo hijo a este nodo.
  void addChild(Node3D child) {
    if (child._parent != null) {
      child._parent!.removeChild(child);
    }
    child._parent = this;
    _children.add(child);
    child.transform.setDirty();
  }

  /// Remueve un nodo hijo.
  void removeChild(Node3D child) {
    if (_children.remove(child)) {
      child._parent = null;
      child.transform.setDirty();
    }
  }

  Node3D? get parent => _parent;
  List<Node3D> get children => List.unmodifiable(_children);

  /// Marca este nodo y todos sus hijos para recalcular transformación.
  void invalidateTransform() {
    transform.setDirty();
    for (final child in _children) {
      child.invalidateTransform();
    }
  }

  /// Actualiza las transformaciones de este nodo y todos los hijos si es necesario.
  void updateTransforms() {
    transform.update(_parent?.transform);
    // Propagar a hijos
    for (final child in _children) {
      child.updateTransforms();
    }
  }

  /// Método virtual para que las subclases dibujen.
  /// Se llama automáticamente al usar [drawScene].
  void draw(Context3D ctx) {
    // Implementado por subclases como ModelNode, etc.
  }

  /// Actualiza y dibuja este nodo y toda su jerarquía recursivamente.
  void drawScene(Context3D ctx) {
    updateTransforms();
    draw(ctx);
    for (final child in _children) {
      child.drawScene(ctx);
    }
  }
}
