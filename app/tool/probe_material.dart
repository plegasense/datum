import 'dart:ffi';
import 'dart:isolate';
import 'package:dovexa/io/cad_loader.dart';
import 'package:dovexa/src/dovexa_ffi.dart';
import 'package:ffi/ffi.dart';

Future<void> main(List<String> a) async {
  final out = await Isolate.run(() {
    final c = a[0].toNativeUtf8();
    final sc = dovexaCadOpen(c, 0.001);
    final res = <String>[];
    final d = malloc<Double>(1);
    for (var i = 0; i < dovexaPartCount(sc) && i < 12; i++) {
      final n = dovexaPartMaterial(sc, i, d).toDartString();
      res.add('${dovexaPartName(sc, i).toDartString()} -> "$n" ${d.value}');
    }
    return res;
  });
  out.forEach(print);
}
