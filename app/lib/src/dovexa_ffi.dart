// Enlace FFI con el núcleo C++ (core/include/dovexa.h). El hook de compilación
// genera la biblioteca y la registra con el identificador de este archivo.
import 'dart:ffi';

import 'package:ffi/ffi.dart';

@Native<Void Function(Pointer<Double>)>(symbol: 'dovexa_cad_timing')
external void dovexaCadTiming(Pointer<Double> out5);

@Native<Void Function(Pointer<Utf8>)>(symbol: 'dovexa_cad_set_cache_file')
external void dovexaCadSetCacheFile(Pointer<Utf8> path);

@Native<Void Function(Int32)>(symbol: 'dovexa_cad_set_lean')
external void dovexaCadSetLean(int lean);

@Native<Pointer<Void> Function(Pointer<Utf8>, Double)>(symbol: 'dovexa_cad_open')
external Pointer<Void> dovexaCadOpen(Pointer<Utf8> path, double relDeflection);

@Native<Pointer<Utf8> Function()>(symbol: 'dovexa_last_error')
external Pointer<Utf8> dovexaLastError();

@Native<Void Function(Pointer<Void>)>(symbol: 'dovexa_scene_free')
external void dovexaSceneFree(Pointer<Void> scene);

@Native<Int Function(Pointer<Void>)>(symbol: 'dovexa_part_count')
external int dovexaPartCount(Pointer<Void> scene);

@Native<Pointer<Utf8> Function(Pointer<Void>, Int)>(symbol: 'dovexa_part_name')
external Pointer<Utf8> dovexaPartName(Pointer<Void> scene, int part);

@Native<LongLong Function(Pointer<Void>, Int)>(
  symbol: 'dovexa_part_vertex_count',
)
external int dovexaPartVertexCount(Pointer<Void> scene, int part);

@Native<Pointer<Float> Function(Pointer<Void>, Int)>(
  symbol: 'dovexa_part_vertices',
)
external Pointer<Float> dovexaPartVertices(Pointer<Void> scene, int part);

@Native<Pointer<Utf8> Function(Pointer<Void>, Int, Pointer<Double>)>(
  symbol: 'dovexa_part_material',
)
external Pointer<Utf8> dovexaPartMaterial(
  Pointer<Void> scene,
  int part,
  Pointer<Double> density,
);

@Native<UnsignedInt Function(Pointer<Void>, Int)>(symbol: 'dovexa_part_color')
external int dovexaPartColor(Pointer<Void> scene, int part);

@Native<Int Function(Pointer<Void>)>(symbol: 'dovexa_node_count')
external int dovexaNodeCount(Pointer<Void> scene);

@Native<Pointer<Utf8> Function(Pointer<Void>, Int)>(symbol: 'dovexa_node_name')
external Pointer<Utf8> dovexaNodeName(Pointer<Void> scene, int node);

@Native<Int Function(Pointer<Void>, Int)>(symbol: 'dovexa_node_parent')
external int dovexaNodeParent(Pointer<Void> scene, int node);

@Native<Int Function(Pointer<Void>, Int)>(symbol: 'dovexa_node_part')
external int dovexaNodePart(Pointer<Void> scene, int node);

@Native<Pointer<Double> Function(Pointer<Void>, Int)>(
  symbol: 'dovexa_node_matrix',
)
external Pointer<Double> dovexaNodeMatrix(Pointer<Void> scene, int node);

@Native<UnsignedInt Function(Pointer<Void>, Int)>(symbol: 'dovexa_node_color')
external int dovexaNodeColor(Pointer<Void> scene, int node);

@Native<Pointer<Utf8> Function(Pointer<Void>)>(symbol: 'dovexa_file_unit')
external Pointer<Utf8> dovexaFileUnit(Pointer<Void> scene);

@Native<Pointer<Utf8> Function(Pointer<Void>)>(symbol: 'dovexa_file_origin')
external Pointer<Utf8> dovexaFileOrigin(Pointer<Void> scene);

@Native<Pointer<Utf8> Function(Pointer<Void>)>(symbol: 'dovexa_file_schema')
external Pointer<Utf8> dovexaFileSchema(Pointer<Void> scene);

@Native<Int Function(Pointer<Void>, Int)>(symbol: 'dovexa_part_face_count')
external int dovexaPartFaceCount(Pointer<Void> scene, int part);

@Native<Pointer<Int32> Function(Pointer<Void>, Int)>(
  symbol: 'dovexa_part_face_of_triangle',
)
external Pointer<Int32> dovexaPartFaceOfTriangle(Pointer<Void> scene, int part);

@Native<Void Function(Pointer<Void>, Int, Int, Pointer<Double>)>(
  symbol: 'dovexa_part_face_info',
)
external void dovexaPartFaceInfo(
  Pointer<Void> scene,
  int part,
  int face,
  Pointer<Double> out,
);

@Native<LongLong Function(Pointer<Void>, Int)>(
  symbol: 'dovexa_part_edge_segment_count',
)
external int dovexaPartEdgeSegmentCount(Pointer<Void> scene, int part);

@Native<Pointer<Float> Function(Pointer<Void>, Int)>(
  symbol: 'dovexa_part_edge_segments',
)
external Pointer<Float> dovexaPartEdgeSegments(Pointer<Void> scene, int part);

@Native<Pointer<Int32> Function(Pointer<Void>, Int)>(
  symbol: 'dovexa_part_edge_of_segment',
)
external Pointer<Int32> dovexaPartEdgeOfSegment(Pointer<Void> scene, int part);

@Native<Int Function(Pointer<Void>, Int)>(symbol: 'dovexa_part_edge_count')
external int dovexaPartEdgeCount(Pointer<Void> scene, int part);

@Native<Void Function(Pointer<Void>, Int, Int, Pointer<Double>)>(
  symbol: 'dovexa_part_edge_info',
)
external void dovexaPartEdgeInfo(
  Pointer<Void> scene,
  int part,
  int edge,
  Pointer<Double> out,
);

@Native<Void Function(Pointer<Void>, Int, Pointer<Double>)>(
  symbol: 'dovexa_part_props',
)
external void dovexaPartProps(
  Pointer<Void> scene,
  int part,
  Pointer<Double> out,
);

@Native<
  Int Function(
    Pointer<Void>,
    Int,
    Int,
    Int,
    Pointer<Double>,
    Int,
    Int,
    Int,
    Pointer<Double>,
    Pointer<Double>,
  )
>(symbol: 'dovexa_distance')
external int dovexaDistance(
  Pointer<Void> scene,
  int partA,
  int kindA,
  int idxA,
  Pointer<Double> mA,
  int partB,
  int kindB,
  int idxB,
  Pointer<Double> mB,
  Pointer<Double> out,
);

@Native<Int Function(Pointer<Void>)>(symbol: 'dovexa_pmi_count')
external int dovexaPmiCount(Pointer<Void> scene);

@Native<Void Function(Pointer<Void>, Int, Pointer<Double>)>(
  symbol: 'dovexa_pmi_info',
)
external void dovexaPmiInfo(Pointer<Void> scene, int i, Pointer<Double> out);

@Native<Pointer<Utf8> Function(Pointer<Void>, Int)>(symbol: 'dovexa_pmi_text')
external Pointer<Utf8> dovexaPmiText(Pointer<Void> scene, int i);

@Native<Int Function(Pointer<Void>, Int)>(symbol: 'dovexa_pmi_ref_count')
external int dovexaPmiRefCount(Pointer<Void> scene, int i);

@Native<Void Function(Pointer<Void>, Int, Int, Pointer<Int32>)>(
  symbol: 'dovexa_pmi_ref',
)
external void dovexaPmiRef(
  Pointer<Void> scene,
  int i,
  int k,
  Pointer<Int32> out3,
);

@Native<LongLong Function(Pointer<Void>, Int)>(
  symbol: 'dovexa_pmi_segment_count',
)
external int dovexaPmiSegmentCount(Pointer<Void> scene, int i);

@Native<Pointer<Float> Function(Pointer<Void>, Int)>(
  symbol: 'dovexa_pmi_segments',
)
external Pointer<Float> dovexaPmiSegments(Pointer<Void> scene, int i);

// ---- Draco (glTF KHR_draco_mesh_compression)

@Native<Pointer<Void> Function(Pointer<Uint8>, UnsignedLong)>(symbol: 'dovexa_draco_decode')
external Pointer<Void> dovexaDracoDecode(Pointer<Uint8> data, int size);

@Native<Pointer<Utf8> Function()>(symbol: 'dovexa_draco_error')
external Pointer<Utf8> dovexaDracoError();

@Native<Int Function(Pointer<Void>)>(symbol: 'dovexa_draco_points')
external int dovexaDracoPoints(Pointer<Void> d);

@Native<Int Function(Pointer<Void>)>(symbol: 'dovexa_draco_faces')
external int dovexaDracoFaces(Pointer<Void> d);

@Native<Void Function(Pointer<Void>, Pointer<Uint32>)>(symbol: 'dovexa_draco_indices')
external void dovexaDracoIndices(Pointer<Void> d, Pointer<Uint32> out);

@Native<Int Function(Pointer<Void>, Int)>(symbol: 'dovexa_draco_attr_components')
external int dovexaDracoAttrComponents(Pointer<Void> d, int uniqueId);

@Native<Int Function(Pointer<Void>, Int, Pointer<Float>)>(symbol: 'dovexa_draco_attr')
external int dovexaDracoAttr(Pointer<Void> d, int uniqueId, Pointer<Float> out);

@Native<Void Function(Pointer<Void>)>(symbol: 'dovexa_draco_free')
external void dovexaDracoFree(Pointer<Void> d);

// ---- LAZ (LASzip)
@Native<Pointer<Void> Function(Pointer<Utf8>)>(symbol: 'dovexa_laz_open')
external Pointer<Void> dovexaLazOpen(Pointer<Utf8> path);

@Native<Pointer<Utf8> Function()>(symbol: 'dovexa_laz_error')
external Pointer<Utf8> dovexaLazError();

@Native<LongLong Function(Pointer<Void>)>(symbol: 'dovexa_laz_count')
external int dovexaLazCount(Pointer<Void> h);

@Native<Int Function(Pointer<Void>, Pointer<Uint8>, Int)>(symbol: 'dovexa_laz_read')
external int dovexaLazRead(Pointer<Void> h, Pointer<Uint8> out, int n);

@Native<Void Function(Pointer<Void>)>(symbol: 'dovexa_laz_free')
external void dovexaLazFree(Pointer<Void> h);
