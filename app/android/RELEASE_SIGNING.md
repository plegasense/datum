# Firma de Android

La clave de subida está en la carpeta `claves/` del proyecto (`dovexa-upload-key.jks` y `key.properties`),
que `.gitignore` excluye: nunca se sube a git. Ahí está también la copia cifrada de la clave (`*.tar.enc`).
Gradle lee `key.properties` de ahí; otra ruta con la variable `DOVEXA_KEY_PROPERTIES`.

Hay que guardar además una copia fuera de este ordenador: sin ellos no se pueden subir versiones nuevas
con la misma clave sin pasar por el restablecimiento de Play Console. Activar Play App Signing al
crear la app (la clave local es solo la de subida).
