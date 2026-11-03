import 'package:datum/model/mesh.dart';
import 'package:datum/render/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' as vm;

void main() {
  test('el modelo queda dentro del volumen de visión', () {
    final cam = OrbitCamera()..aspect = 402 / 874;
    cam.setView(-0.785, 0.615);
    final b = Bounds([10, 10, -6], [90, 70, 5]);
    cam.fit(b);
    final mvp = cam.projection(402 / 874) * cam.viewMatrix();
    for (final x in [10.0, 90.0]) {
      for (final y in [10.0, 70.0]) {
        for (final z in [-6.0, 5.0]) {
          final v = vm.Vector4(x, y, z, 1)..applyMatrix4(mvp);
          // ignore: avoid_print
          print(
            '($x,$y,$z) -> ndc ${(v.x / v.w).toStringAsFixed(2)}, ${(v.y / v.w).toStringAsFixed(2)}, z ${(v.z / v.w).toStringAsFixed(3)} w ${v.w.toStringAsFixed(1)}',
          );
          expect(v.z / v.w, inInclusiveRange(0.0, 1.0));
        }
      }
    }
    // ignore: avoid_print
    print('distance ${cam.distance} radius ${cam.sceneRadius}');
  });
}
