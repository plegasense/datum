# Firma de Android

La clave de subida está fuera del repositorio, en
`~/Library/Application Support/Dovexa/signing/` (`datum-upload-key.jks` y `key.properties`).
Gradle lee `key.properties` de ahí; otra ruta con la variable `DATUM_KEY_PROPERTIES`.

Hay que guardar copia cifrada de ambos archivos: sin ellos no se pueden subir versiones nuevas
con la misma clave sin pasar por el restablecimiento de Play Console. Activar Play App Signing al
crear la app (la clave local es solo la de subida).
