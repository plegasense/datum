// Versión vacía de la API, para arquitecturas sin Open CASCADE (p. ej. el simulador de iOS en Intel).
#include "datum.h"

extern "C" {
DatumScene* datum_cad_open(const char*, double) { return nullptr; }
void datum_cad_set_lean(int) {}
void datum_cad_set_cache_file(const char*) {}
const char* datum_part_material(const DatumScene*, int, double* d) { *d = 0; return ""; }
void datum_cad_timing(double*) {}
const char* datum_last_error(void) { return "Este formato no está disponible en esta arquitectura."; }
void datum_scene_free(DatumScene*) {}
int datum_part_count(const DatumScene*) { return 0; }
const char* datum_part_name(const DatumScene*, int) { return ""; }
long long datum_part_vertex_count(const DatumScene*, int) { return 0; }
const float* datum_part_vertices(const DatumScene*, int) { return nullptr; }
unsigned int datum_part_color(const DatumScene*, int) { return 0; }
int datum_node_count(const DatumScene*) { return 0; }
const char* datum_node_name(const DatumScene*, int) { return ""; }
int datum_node_parent(const DatumScene*, int) { return -1; }
int datum_node_part(const DatumScene*, int) { return -1; }
const double* datum_node_matrix(const DatumScene*, int) { return nullptr; }
unsigned int datum_node_color(const DatumScene*, int) { return 0; }
const char* datum_file_unit(const DatumScene*) { return "MM"; }
const char* datum_file_origin(const DatumScene*) { return ""; }
const char* datum_file_schema(const DatumScene*) { return ""; }
int datum_part_face_count(const DatumScene*, int) { return 0; }
const int* datum_part_face_of_triangle(const DatumScene*, int) { return nullptr; }
void datum_part_face_info(DatumScene*, int, int, double*) {}
long long datum_part_edge_segment_count(const DatumScene*, int) { return 0; }
const float* datum_part_edge_segments(const DatumScene*, int) { return nullptr; }
const int* datum_part_edge_of_segment(const DatumScene*, int) { return nullptr; }
int datum_part_edge_count(const DatumScene*, int) { return 0; }
void datum_part_edge_info(const DatumScene*, int, int, double*) {}
void datum_part_props(DatumScene*, int, double*) {}
int datum_distance(const DatumScene*, int, int, int, const double*, int, int, int, const double*, double*) { return 0; }
int datum_pmi_count(const DatumScene*) { return 0; }
void datum_pmi_info(const DatumScene*, int, double*) {}
const char* datum_pmi_text(const DatumScene*, int) { return ""; }
int datum_pmi_ref_count(const DatumScene*, int) { return 0; }
void datum_pmi_ref(const DatumScene*, int, int, int*) {}
long long datum_pmi_segment_count(const DatumScene*, int) { return 0; }
const float* datum_pmi_segments(const DatumScene*, int) { return nullptr; }
}

// Draco no está disponible en esta arquitectura (simulador de iOS en Intel).
DatumDraco* datum_draco_decode(const unsigned char*, unsigned long) { return nullptr; }
const char* datum_draco_error(void) { return "Draco no está disponible en esta arquitectura."; }
int datum_draco_points(const DatumDraco*) { return 0; }
int datum_draco_faces(const DatumDraco*) { return 0; }
void datum_draco_indices(const DatumDraco*, unsigned int*) {}
int datum_draco_attr_components(const DatumDraco*, int) { return 0; }
int datum_draco_attr(const DatumDraco*, int, float*) { return 0; }
void datum_draco_free(DatumDraco*) {}

DatumLaz* datum_laz_open(const char*) { return nullptr; }
const char* datum_laz_error(void) { return "LAZ no está disponible en esta arquitectura."; }
long long datum_laz_count(const DatumLaz*) { return 0; }
int datum_laz_read(DatumLaz*, unsigned char*, int) { return 0; }
void datum_laz_free(DatumLaz*) {}
