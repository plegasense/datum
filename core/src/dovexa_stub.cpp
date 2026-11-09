// Versión vacía de la API, para arquitecturas sin Open CASCADE (p. ej. el simulador de iOS en Intel).
#include "dovexa.h"

extern "C" {
DovexaScene* dovexa_cad_open(const char*, double) { return nullptr; }
void dovexa_cad_set_lean(int) {}
void dovexa_cad_set_cache_file(const char*) {}
const char* dovexa_part_material(const DovexaScene*, int, double* d) { *d = 0; return ""; }
void dovexa_cad_timing(double*) {}
const char* dovexa_last_error(void) { return "Este formato no está disponible en esta arquitectura."; }
void dovexa_scene_free(DovexaScene*) {}
int dovexa_part_count(const DovexaScene*) { return 0; }
const char* dovexa_part_name(const DovexaScene*, int) { return ""; }
long long dovexa_part_vertex_count(const DovexaScene*, int) { return 0; }
const float* dovexa_part_vertices(const DovexaScene*, int) { return nullptr; }
unsigned int dovexa_part_color(const DovexaScene*, int) { return 0; }
int dovexa_node_count(const DovexaScene*) { return 0; }
const char* dovexa_node_name(const DovexaScene*, int) { return ""; }
int dovexa_node_parent(const DovexaScene*, int) { return -1; }
int dovexa_node_part(const DovexaScene*, int) { return -1; }
const double* dovexa_node_matrix(const DovexaScene*, int) { return nullptr; }
unsigned int dovexa_node_color(const DovexaScene*, int) { return 0; }
const char* dovexa_file_unit(const DovexaScene*) { return "MM"; }
const char* dovexa_file_origin(const DovexaScene*) { return ""; }
const char* dovexa_file_schema(const DovexaScene*) { return ""; }
int dovexa_part_face_count(const DovexaScene*, int) { return 0; }
const int* dovexa_part_face_of_triangle(const DovexaScene*, int) { return nullptr; }
void dovexa_part_face_info(DovexaScene*, int, int, double*) {}
long long dovexa_part_edge_segment_count(const DovexaScene*, int) { return 0; }
const float* dovexa_part_edge_segments(const DovexaScene*, int) { return nullptr; }
const int* dovexa_part_edge_of_segment(const DovexaScene*, int) { return nullptr; }
int dovexa_part_edge_count(const DovexaScene*, int) { return 0; }
void dovexa_part_edge_info(const DovexaScene*, int, int, double*) {}
void dovexa_part_props(DovexaScene*, int, double*) {}
int dovexa_distance(const DovexaScene*, int, int, int, const double*, int, int, int, const double*, double*) { return 0; }
int dovexa_pmi_count(const DovexaScene*) { return 0; }
void dovexa_pmi_info(const DovexaScene*, int, double*) {}
const char* dovexa_pmi_text(const DovexaScene*, int) { return ""; }
int dovexa_pmi_ref_count(const DovexaScene*, int) { return 0; }
void dovexa_pmi_ref(const DovexaScene*, int, int, int*) {}
long long dovexa_pmi_segment_count(const DovexaScene*, int) { return 0; }
const float* dovexa_pmi_segments(const DovexaScene*, int) { return nullptr; }
}

// Draco no está disponible en esta arquitectura (simulador de iOS en Intel).
DovexaDraco* dovexa_draco_decode(const unsigned char*, unsigned long) { return nullptr; }
const char* dovexa_draco_error(void) { return "Draco no está disponible en esta arquitectura."; }
int dovexa_draco_points(const DovexaDraco*) { return 0; }
int dovexa_draco_faces(const DovexaDraco*) { return 0; }
void dovexa_draco_indices(const DovexaDraco*, unsigned int*) {}
int dovexa_draco_attr_components(const DovexaDraco*, int) { return 0; }
int dovexa_draco_attr(const DovexaDraco*, int, float*) { return 0; }
void dovexa_draco_free(DovexaDraco*) {}

DovexaLaz* dovexa_laz_open(const char*) { return nullptr; }
const char* dovexa_laz_error(void) { return "LAZ no está disponible en esta arquitectura."; }
long long dovexa_laz_count(const DovexaLaz*) { return 0; }
int dovexa_laz_read(DovexaLaz*, unsigned char*, int) { return 0; }
void dovexa_laz_free(DovexaLaz*) {}
