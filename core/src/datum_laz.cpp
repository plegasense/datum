// Lectura de LAZ (LAS comprimido) con LASzip (Apache-2.0, Rapidlasso). Cada punto leído se vuelve a
// empaquetar como registro LAS sin comprimir del mismo formato y longitud que declara la cabecera.
#include <cstdint>
#include <cstring>
#include <string>

#include "datum.h"
#include "laszip_api.h"

struct DatumLaz {
  laszip_POINTER reader = nullptr;
  laszip_header* header = nullptr;
  laszip_point* point = nullptr;
  int format = 0;
  int record_length = 0;
  long long count = 0;
};

static thread_local std::string g_laz_error;

static void put16(unsigned char* o, int off, uint16_t v) { std::memcpy(o + off, &v, 2); }
static void put32(unsigned char* o, int off, int32_t v) { std::memcpy(o + off, &v, 4); }
static void putf64(unsigned char* o, int off, double v) { std::memcpy(o + off, &v, 8); }

static void pack(const laszip_point* p, int fmt, int rl, unsigned char* o) {
  std::memset(o, 0, rl);
  put32(o, 0, p->X);
  put32(o, 4, p->Y);
  put32(o, 8, p->Z);
  put16(o, 12, p->intensity);
  int base;
  if (fmt <= 5) {
    o[14] = (p->return_number & 7) | ((p->number_of_returns & 7) << 3) | (p->scan_direction_flag << 6) |
            (p->edge_of_flight_line << 7);
    o[15] = (p->classification & 31) | (p->synthetic_flag << 5) | (p->keypoint_flag << 6) | (p->withheld_flag << 7);
    o[16] = static_cast<unsigned char>(p->scan_angle_rank);
    o[17] = p->user_data;
    put16(o, 18, p->point_source_ID);
    if (fmt == 1 || fmt == 3 || fmt == 4 || fmt == 5) putf64(o, 20, p->gps_time);
    if (fmt == 2) {
      put16(o, 20, p->rgb[0]);
      put16(o, 22, p->rgb[1]);
      put16(o, 24, p->rgb[2]);
    }
    if (fmt == 3 || fmt == 5) {
      put16(o, 28, p->rgb[0]);
      put16(o, 30, p->rgb[1]);
      put16(o, 32, p->rgb[2]);
    }
    static const int kBase[] = {20, 28, 26, 34, 57, 63};
    base = kBase[fmt];
  } else {
    o[14] = (p->extended_return_number & 15) | ((p->extended_number_of_returns & 15) << 4);
    o[15] = (p->extended_classification_flags & 15) | ((p->extended_scanner_channel & 3) << 4) |
            (p->scan_direction_flag << 6) | (p->edge_of_flight_line << 7);
    o[16] = p->extended_classification;
    o[17] = p->user_data;
    put16(o, 18, static_cast<uint16_t>(p->extended_scan_angle));
    put16(o, 20, p->point_source_ID);
    putf64(o, 22, p->gps_time);
    if (fmt == 7 || fmt == 8 || fmt == 10) {
      put16(o, 30, p->rgb[0]);
      put16(o, 32, p->rgb[1]);
      put16(o, 34, p->rgb[2]);
    }
    if (fmt == 8) put16(o, 36, p->rgb[3]);
    static const int kBase[] = {0, 0, 0, 0, 0, 0, 30, 36, 38, 59, 67};
    base = kBase[fmt];
  }
  if (p->num_extra_bytes > 0 && p->extra_bytes && base < rl) {
    int n = rl - base;
    if (n > p->num_extra_bytes) n = p->num_extra_bytes;
    std::memcpy(o + base, p->extra_bytes, n);
  }
}

extern "C" {

DatumLaz* datum_laz_open(const char* path) {
  g_laz_error.clear();
  laszip_POINTER r = nullptr;
  if (laszip_create(&r)) {
    g_laz_error = "No se pudo iniciar LASzip";
    return nullptr;
  }
  laszip_BOOL compressed = 0;
  if (laszip_open_reader(r, path, &compressed)) {
    laszip_CHAR* msg = nullptr;
    laszip_get_error(r, &msg);
    g_laz_error = msg ? msg : "No se pudo abrir el LAZ";
    laszip_destroy(r);
    return nullptr;
  }
  auto* h = new DatumLaz();
  h->reader = r;
  laszip_get_header_pointer(r, &h->header);
  laszip_get_point_pointer(r, &h->point);
  h->format = h->header->point_data_format;
  h->record_length = h->header->point_data_record_length;
  h->count = h->header->extended_number_of_point_records ? static_cast<long long>(h->header->extended_number_of_point_records)
                                                         : static_cast<long long>(h->header->number_of_point_records);
  if (h->format < 0 || h->format > 10) {
    g_laz_error = "Formato de punto LAS desconocido";
    laszip_close_reader(r);
    laszip_destroy(r);
    delete h;
    return nullptr;
  }
  return h;
}

const char* datum_laz_error(void) { return g_laz_error.c_str(); }

long long datum_laz_count(const DatumLaz* h) { return h ? h->count : 0; }

int datum_laz_read(DatumLaz* h, unsigned char* out, int n) {
  if (!h) return 0;
  int i = 0;
  for (; i < n; ++i) {
    if (laszip_read_point(h->reader)) {
      laszip_CHAR* msg = nullptr;
      laszip_get_error(h->reader, &msg);
      g_laz_error = msg ? msg : "Error al descomprimir el LAZ";
      break;
    }
    pack(h->point, h->format, h->record_length, out + static_cast<size_t>(i) * h->record_length);
  }
  return i;
}

void datum_laz_free(DatumLaz* h) {
  if (!h) return;
  laszip_close_reader(h->reader);
  laszip_destroy(h->reader);
  delete h;
}

}
