import 'package:dovexa/io/loader.dart';
import 'package:dovexa/model/document.dart';
import 'package:dovexa/render/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' as vm;

void main() {
  test('glTF: límites y encuadre', () async {
    final d =
        await loadDocument('../testdata/formatos/escena.glb') as ModelDocument;
    final b = d.scene.bounds();
    // ignore: avoid_print
    print('bounds ${b.min} ${b.max} radius ${b.radius}');
    for (final i in d.scene.instances(onlyVisible: false)) {
      // ignore: avoid_print
      print(
        '${i.node.name} part bounds ${i.part.mesh.bounds.min} ${i.part.mesh.bounds.max}\n${i.world}',
      );
    }
    final cam = OrbitCamera()..aspect = 0.46;
    cam.setView(-0.785, 0.615);
    cam.fit(b);
    // ignore: avoid_print
    print('dist ${cam.distance} target ${cam.target} eye ${cam.eye}');
    final mvp = cam.projection(0.46) * cam.viewMatrix();
    for (final p in [b.min, b.max]) {
      final v = vm.Vector4(p[0], p[1], p[2], 1)..applyMatrix4(mvp);
      // ignore: avoid_print
      print('$p -> ${v.x / v.w}, ${v.y / v.w}');
    }
  });
}
