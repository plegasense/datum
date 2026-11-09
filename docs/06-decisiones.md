# 06 · Decisiones

Registro de decisiones. Estado: **Abierta**, **Propuesta** (con recomendación) o **Cerrada**.

## Cerradas
| ID | Decisión | Motivo |
|---|---|---|
| D-00a | Nombre: **Dovexa** | Nombre inventado; sin marcas idénticas en UE, EE. UU. ni Reino Unido; sin conflicto en Play Store |
| D-00b | **iOS y Android** | Tu decisión. Sustituye a "solo Android", y cambia la arquitectura (ver `03-arquitectura.md`) |
| D-00c | Logo: vista explosionada de ensamblaje, ver `branding/` | Tu decisión |
| D-00d | Gratis, sin anuncios, sin cuenta, sin conexión | Tu decisión; es también la ventaja frente a Fast STL Viewer |

## Abiertas: necesito que decidas

### D-10 · Interfaz compartida
**Recomendación: Flutter** para la interfaz y C++ para el núcleo y el visor. Ya tienes Flutter instalado, hay una sola UI para las dos plataformas, y el visor 3D es C++ en una superficie nativa.
- Riesgo: incrustar el visor 3D nativo con fluidez dentro de Flutter. Se comprueba en M0.
- Plan B si falla: dos carcasas nativas finas (SwiftUI y Compose) sobre el mismo núcleo.
- Alternativa: Kotlin/Compose Multiplatform. Menos maduro en iOS.

### D-01 · Licencia del código — **DECIDIDA: GPL-3.0 (25/10/2026)**
Decisión tuya, siguiendo mi recomendación. Motivos:
- Con la App Store cerrada (D-11) desaparece el único inconveniente de la GPL.
- Encaja con la promesa de «gratis y sin anuncios»: cualquier copia o versión modificada debe publicar su código con la misma licencia, así que nadie puede sacar un clon cerrado o con publicidad.
- Abre la puerta a LibreDWG (GPLv3) para leer DWG, hoy fuera de alcance (D-02).
Consecuencias:
- El texto completo está en `LICENSE` (raíz) y los avisos de terceros en `NOTICE.md`.
- Las librerías que usamos son compatibles: Open CASCADE (LGPL con excepción), Draco y LASzip (Apache-2.0), Roboto (Apache-2.0).
- Si algún día se quisiera publicar en App Store habría que relicenciar; solo puede hacerlo el autor.
- Ninguna licencia garantiza «gratis para siempre»; la GPL lo hace casi exigible a quien copie el código.

### D-02 · DXF y DWG
**Cerrada en la práctica:** DXF con **lector propio** (sin GPL). **DWG queda fuera por ahora**: LibreDWG (GPLv3) no es compatible con la App Store; la única vía legítima es el SDK comercial de Open Design Alliance, que se evaluará después.

### D-03 · Capa gráfica: bgfx o Filament
Ya no basta con OpenGL ES: en iOS está en desuso, hace falta Metal. Las dos candidatas son multiplataforma (Metal, Vulkan, OpenGL ES). Se decide en M0 con una prueba de aristas, secciones y selección. Hipótesis: bgfx, por el control de bajo nivel.

### D-04 · Formatos propietarios (`.sldprt`, `.ipt`, `.prt`…)
**Recomendación:** que v1.0 **no los abra directamente**; detectar, explicar y guiar al usuario para exportar a STEP. Reevaluar el SDK de Open Design Alliance después, sabiendo que cuesta dinero y/o envía archivos fuera del móvil.
La decisión importante: ¿aceptas que, al principio, no se abran sin exportar?

### D-04b · Precio de las licencias para abrir formatos nativos (24/10/2026)
- **Open Design Alliance (ODA)**, según su [página de membresías](https://www.opendesign.com/oda-membership): *Commercial* 3.000 USD el primer año y 2.250 de renovación (hasta 100 copias redistribuidas, **sin extensiones**); *Sustaining* 7.500 y 4.500 al año (redistribución ilimitada, extensiones de pago); *Founding* 37.500 y 18.000 (con código fuente).
- **Conflicto:** su [calculadora de planes](https://www.opendesign.com/pricing/plan-calculator) muestra 99.999 USD al año para un plan comercial de 100 puestos. No sé cuál es el actual.
- **Extensión Mecánica (SolidWorks, Inventor, NX, Creo):** no aparece precio. Su web ofrece una prueba de 60 días solo para SolidWorks e Inventor.
- **CAD Exchanger:** su programa de escritorio cuesta unos 590 USD al año por usuario según agregadores; el precio del SDK para integrarlo en una app no está publicado. HOOPS Exchange y Datakit: sin precio público.
- **Conclusión honesta:** abrir `.sldprt`, `.ipt`, `.prt` desde una app gratuita costaría, como mínimo, miles de dólares al año, y probablemente decenas de miles. Pide presupuesto antes de decidir.

### D-04c · ¿Es legal la ingeniería inversa de un formato como `.ipt`?
**No soy abogado y esto no es asesoramiento legal.** Lo que he encontrado:
- **UE (incluida España):** la Directiva 2009/24/CE, [artículo 6](https://lwn.net/Articles/134642/), permite descompilar sin permiso del titular cuando es indispensable para lograr la **interoperabilidad** de un programa creado de forma independiente, con límites (solo lo necesario, sin usar la información para un programa sustancialmente similar, sin publicarla). El artículo 9 declara inaplicables las cláusulas contractuales que lo prohíben.
- **EE. UU.:** el DMCA §1201(f) también ampara la interoperabilidad; siguen aplicando derechos de autor, secreto comercial y licencias de uso.
- **Matiz importante:** analizar *archivos* de un formato no es lo mismo que descompilar *el programa*. Hay análisis jurídicos que señalan que copiar la estructura de datos de un formato puede plantear cuestiones de derechos de autor. No encontré ninguna sentencia sobre formatos CAD.
- **Obstáculo técnico:** `.ipt` es un contenedor OLE2 con la geometría del núcleo ShapeManager (derivado de ACIS), y el formato cambia cada año. Un proyecto comunitario (InventorLoader) lo intentó para Inventor 2010 o posterior, y no parece mantenido.
- **Recomendación:** no hacerlo por tu cuenta. Opciones razonables: guiar la exportación a STEP (ya hecho), pedir presupuesto a un SDK, o consultar a un abogado de propiedad intelectual antes de invertir tiempo.

### D-05 · Cuenta de Google Play: **ya existe** (con varias apps)
Falta un dato: la exigencia de **12 testers durante 14 días** solo aplica a cuentas personales creadas después del 13/11/2023 (según Google y fuentes secundarias). Si tu cuenta es anterior, queda exenta. **¿De qué año es tu cuenta de Play Console?** Cuanto antes lo sepamos, antes sabemos si hay que reclutar testers.

### D-11 · App Store de Apple: **cerrada, no se publica**
Decisión tuya: Dovexa no saldrá en la App Store. iOS se mantiene como plataforma **soportada en el código** (Flutter + núcleo C++ compartido), para uso propio y pruebas en simulador o en tu iPhone por cable con tu identidad "Apple Development". Quedan fuera TestFlight, la ficha de App Store y la cuenta de pago de Apple. Si algún día cambia, hay que revisar D-01 (la GPL choca con la App Store).

### D-06 · Identificadores de la app
No se pueden cambiar una vez publicada. Propuesta: `app.datum.datum` para Android y el mismo para iOS (Bundle ID), o uno ligado a un dominio tuyo si lo tienes.

### D-07 · Repositorio
GitHub **público o privado**. Con la GPL-3.0 (D-01) puede ser público para generar confianza ("nada sale de tu móvil" se puede comprobar).

### D-08 · Móviles físicos de pruebas
Ahora no hay ninguno conectado. Para medir rendimiento real de GPU hace falta un móvil físico por plataforma: idealmente de gama media, no el tope de gama. ¿Qué iPhone y qué Android tienes?

### D-09 · Telemetría
**Recomendación:** ninguna. Sin permiso de Internet en Android, sin analítica en ninguna. Los vitales de Play Console y los informes de App Store Connect dan instalaciones y fallos sin añadir nada.

## Propuestas técnicas ya asumidas (revocables)
- Android minSdk 26, targetSdk 36 (Google exige 36 a apps nuevas desde el 31/08/2026). iOS 17 o superior.
- Caché binaria de mallas por huella de archivo.
- Español e inglés desde el primer día.
- OCCT enlazado como framework dinámico en iOS.

## Fuentes de los datos clave
- Descargas y notas: consulta directa a Google Play (octubre 2026), rangos.
- Reseñas de Fast STL Viewer, Autodesk Fusion y Onshape: leídas en Google Play.
- Requisito de prueba cerrada: [ayuda de Google Play](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-GB).
- Target API 36: [documentación de Android](https://developer.android.com/google/play/requirements/target-sdk).
- Compilar OCCT en Android: [guía oficial](https://dev.opencascade.org/doc/occt-7.3.0/overview/html/samples_java_android_occt.html) (versiones 7.x).
- Licencia de OCCT (LGPL con excepción): [hilo de Fedora](https://lists.pagure.io/archives/list/legal@lists.fedoraproject.org/message/OFHQXSYC2PXDWBLZ22VG72RQOSNHR35Q/); versión 8.0: [anuncio](https://forum.kicad.info/t/open-cascade-technology-version-8-0-0-to-the-public/68991).
- LGPL y App Store (enlace dinámico): [foro de VideoLAN](https://forum.videolan.org/viewtopic.php?p=535282). Es opinión de desarrolladores, no criterio legal.
- SDK de formatos propietarios: [Open Design Alliance, MCAD SDK](https://www.opendesign.com/products/mcad-sdk).
- Licencias DXF y DWG: [LibreDWG](https://en.wikipedia.org/wiki/LibreDWG).
