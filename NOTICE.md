# Datum — licencia y avisos de terceros

Datum se publica bajo la **GNU General Public License v3.0** (ver `LICENSE`).

## Componentes de terceros incluidos o enlazados
| Componente | Uso | Licencia |
|---|---|---|
| Open CASCADE Technology 8.0.1 | Lectura de STEP, IGES y BREP (enlazado estático, sin modificar; fuente: https://github.com/Open-Cascade-SAS/OCCT/tree/V8_0_1) | LGPL-2.1 con excepción de OCCT |
| Draco (Google) | Descompresión de mallas glTF | Apache-2.0 (`third_party/draco`) |
| LASzip (Rapidlasso) | Lectura de LAZ | Apache-2.0 (`third_party/laszip`) |
| Roboto (Google) | Tipografía del nombre en el logotipo (`branding/fonts`) | Apache-2.0 |
| Paquetes de Dart y Flutter | Interfaz, XML, archivos | Ver la página de licencias dentro de la app |

Los archivos de prueba descargados (`testdata/_externos/`) no forman parte del programa: pertenecen a sus autores y mantienen sus licencias (LGPL de J. Burkardt, MIT de three.js, BSD de PDAL, etc.) y no se redistribuyen.
