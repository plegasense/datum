import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../l10n/l10n.dart';
import '../src/dovexa_ffi.dart';

/// Malla descomprimida de un bloque Draco: índices de triángulos y atributos como float.
class DracoPrim {
  DracoPrim(this.points, this.indices, this.attrs);
  final int points;
  final Uint32List indices;

  /// Nombre de glTF (POSITION, NORMAL, TEXCOORD_0…) → valores (puntos × componentes).
  final Map<String, Float32List> attrs;
}

/// Descomprime el bloque Draco de una primitiva de glTF con el decodificador nativo.
/// [attrIds] asocia cada atributo de glTF con el identificador único de Draco.
DracoPrim decodeDraco(Uint8List bytes, Map<String, int> attrIds) {
  final buf = malloc<Uint8>(bytes.length);
  try {
    buf.asTypedList(bytes.length).setAll(0, bytes);
    final h = dovexaDracoDecode(buf, bytes.length);
    if (h == nullptr) {
      final e = dovexaDracoError();
      throw FormatException(
        tr('No se pudo descomprimir Draco: {m}', {
          'm': tr(e == nullptr ? 'error desconocido' : e.toDartString()),
        }),
      );
    }
    try {
      final points = dovexaDracoPoints(h);
      final faces = dovexaDracoFaces(h);
      final ix = malloc<Uint32>(faces * 3 + 1);
      final indices = Uint32List(faces * 3);
      try {
        dovexaDracoIndices(h, ix);
        indices.setAll(0, ix.asTypedList(faces * 3));
      } finally {
        malloc.free(ix);
      }
      final attrs = <String, Float32List>{};
      for (final e in attrIds.entries) {
        final nc = dovexaDracoAttrComponents(h, e.value);
        if (nc <= 0) continue;
        final out = malloc<Float>(points * nc + 1);
        try {
          if (dovexaDracoAttr(h, e.value, out) > 0) {
            attrs[e.key] = Float32List.fromList(out.asTypedList(points * nc));
          }
        } finally {
          malloc.free(out);
        }
      }
      return DracoPrim(points, indices, attrs);
    } finally {
      dovexaDracoFree(h);
    }
  } finally {
    malloc.free(buf);
  }
}
