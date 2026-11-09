// API en C del núcleo de Dovexa. Estable y mínima: la consume Dart por FFI.
#ifndef DOVEXA_H
#define DOVEXA_H

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
#define DOVEXA_API __declspec(dllexport)
#else
#define DOVEXA_API __attribute__((visibility("default"))) __attribute__((used))
#endif

typedef struct DovexaScene DovexaScene;

// Abre un STEP (o IGES/BREP) y lo tesela. Devuelve NULL si falla; entonces
// dovexa_last_error() describe el motivo.
// rel_deflection: error de teselado relativo al tamaño del modelo (p. ej. 0.001).
/* Milisegundos de la última lectura: lectura, conversión, árbol, teselado, anotaciones. */
DOVEXA_API void dovexa_cad_timing(double* out5);
/* Lectura ligera: sin capas, propiedades, materiales ni anotaciones (más rápida). */
DOVEXA_API void dovexa_cad_set_lean(int lean);
/* Archivo de caché del documento convertido para la próxima apertura (solo la llamada siguiente). */
DOVEXA_API void dovexa_cad_set_cache_file(const char* path);
DOVEXA_API DovexaScene* dovexa_cad_open(const char* path, double rel_deflection);
DOVEXA_API const char* dovexa_last_error(void);
DOVEXA_API void dovexa_scene_free(DovexaScene* s);

// Piezas únicas (geometría teselada, vértices intercalados: x y z nx ny nz).
DOVEXA_API int dovexa_part_count(const DovexaScene* s);
DOVEXA_API const char* dovexa_part_name(const DovexaScene* s, int part);
/* Material declarado en el archivo: nombre ('' si no hay) y densidad en g/cm³ (0 = sin dato). */
DOVEXA_API const char* dovexa_part_material(const DovexaScene* s, int part, double* density_g_cm3);
DOVEXA_API long long dovexa_part_vertex_count(const DovexaScene* s, int part);
DOVEXA_API const float* dovexa_part_vertices(const DovexaScene* s, int part);
DOVEXA_API unsigned int dovexa_part_color(const DovexaScene* s, int part);  // 0xAARRGGBB, 0 = sin color

// Árbol de ensamblaje, en orden de recorrido (el padre siempre va antes que el hijo).
DOVEXA_API int dovexa_node_count(const DovexaScene* s);
DOVEXA_API const char* dovexa_node_name(const DovexaScene* s, int node);
DOVEXA_API int dovexa_node_parent(const DovexaScene* s, int node);  // -1 = raíz
DOVEXA_API int dovexa_node_part(const DovexaScene* s, int node);    // -1 = grupo
DOVEXA_API const double* dovexa_node_matrix(const DovexaScene* s, int node);  // 16, column-major
DOVEXA_API unsigned int dovexa_node_color(const DovexaScene* s, int node);

// Unidad de longitud que declara el archivo ("MM", "INCH", "METRE"…) y datos de cabecera.
// La geometría siempre llega en milímetros.
DOVEXA_API const char* dovexa_file_unit(const DovexaScene* s);
DOVEXA_API const char* dovexa_file_origin(const DovexaScene* s);
DOVEXA_API const char* dovexa_file_schema(const DovexaScene* s);

// Caras de cada pieza: cara a la que pertenece cada triángulo y su descripción.
// face_info (14 valores): tipo (0 otra, 1 plano, 2 cilindro, 3 cono, 4 esfera, 5 toro), área, radio,
// radio menor o semiángulo, punto (3), eje (3), longitud, barrido angular, cóncava (1 = agujero).
DOVEXA_API int dovexa_part_face_count(const DovexaScene* s, int part);
DOVEXA_API const int* dovexa_part_face_of_triangle(const DovexaScene* s, int part);
DOVEXA_API void dovexa_part_face_info(DovexaScene* s, int part, int face, double* out14);

// Aristas vivas: segmentos (6 floats) y a qué arista pertenece cada uno.
// edge_info (15): tipo (0 otra, 1 recta, 2 círculo, 3 arco), longitud, radio, centro (3), eje (3), inicio (3), fin (3).
DOVEXA_API long long dovexa_part_edge_segment_count(const DovexaScene* s, int part);
DOVEXA_API const float* dovexa_part_edge_segments(const DovexaScene* s, int part);
DOVEXA_API const int* dovexa_part_edge_of_segment(const DovexaScene* s, int part);
DOVEXA_API int dovexa_part_edge_count(const DovexaScene* s, int part);
DOVEXA_API void dovexa_part_edge_info(const DovexaScene* s, int part, int edge, double* out15);

// Volumen, área, centro de masas y, si el archivo los trae, volumen y área de validación.
DOVEXA_API void dovexa_part_props(DovexaScene* s, int part, double* out8);

// Distancia mínima entre dos entidades (kind 0 = cara, 1 = arista) colocadas con sus matrices (16, columnas).
DOVEXA_API int dovexa_distance(const DovexaScene* s, int part_a, int kind_a, int idx_a, const double* m_a, int part_b,
                             int kind_b, int idx_b, const double* m_b, double* out7);

// Anotaciones del archivo (PMI semántico y gráfico).
// pmi_info (16): clase (0 cota, 1 tolerancia, 2 referencia), tipo (enumeración de OCCT), valor,
// tolerancia superior / límite superior, inferior, indicador (1 ± , 2 rango), calificador,
// tipo de valor de la tolerancia, modificador de material, modificador de zona, punto del texto (3), 4 libres.
// pmi_text: letras de las referencias de una tolerancia (A|B|C), nombre de una referencia o nombre semántico.
DOVEXA_API int dovexa_pmi_count(const DovexaScene* s);
DOVEXA_API void dovexa_pmi_info(const DovexaScene* s, int i, double* out16);
DOVEXA_API const char* dovexa_pmi_text(const DovexaScene* s, int i);
DOVEXA_API int dovexa_pmi_ref_count(const DovexaScene* s, int i);
DOVEXA_API void dovexa_pmi_ref(const DovexaScene* s, int i, int k, int* out3);  // pieza, 0 cara / 1 arista, índice
DOVEXA_API long long dovexa_pmi_segment_count(const DovexaScene* s, int i);
DOVEXA_API const float* dovexa_pmi_segments(const DovexaScene* s, int i);

// Mallas Draco (glTF KHR_draco_mesh_compression). Devuelve null si no se puede descomprimir
// (dovexa_draco_error da el motivo).
typedef struct DovexaDraco DovexaDraco;
DOVEXA_API DovexaDraco* dovexa_draco_decode(const unsigned char* data, unsigned long size);
DOVEXA_API const char* dovexa_draco_error(void);
DOVEXA_API int dovexa_draco_points(const DovexaDraco* d);
DOVEXA_API int dovexa_draco_faces(const DovexaDraco* d);
/* 3 índices por cara (puntos de Draco). */
DOVEXA_API void dovexa_draco_indices(const DovexaDraco* d, unsigned int* out);
DOVEXA_API int dovexa_draco_attr_components(const DovexaDraco* d, int unique_id);
/* Valores del atributo por punto como float (puntos × componentes); devuelve las componentes o 0. */
DOVEXA_API int dovexa_draco_attr(const DovexaDraco* d, int unique_id, float* out);
DOVEXA_API void dovexa_draco_free(DovexaDraco* d);

// Lectura de LAZ (LAS comprimido) con LASzip (Apache-2.0). Devuelve null si falla (dovexa_laz_error
// da el motivo). Cada registro sale en formato LAS sin comprimir, con la longitud de la cabecera.
typedef struct DovexaLaz DovexaLaz;
DOVEXA_API DovexaLaz* dovexa_laz_open(const char* path);
DOVEXA_API const char* dovexa_laz_error(void);
DOVEXA_API long long dovexa_laz_count(const DovexaLaz* h);
/* Lee hasta n registros en out (n × longitud de registro); devuelve los leídos. */
DOVEXA_API int dovexa_laz_read(DovexaLaz* h, unsigned char* out, int n);
DOVEXA_API void dovexa_laz_free(DovexaLaz* h);

#ifdef __cplusplus
}
#endif
#endif
