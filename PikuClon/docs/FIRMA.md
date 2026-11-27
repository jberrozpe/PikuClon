# Firma de la app Android

Los **keystores no están en el repositorio** (ver `.gitignore`) ni sus contraseñas.
Están guardados en la carpeta **PikuClon** de Google Drive, junto a
`CREDENCIALES.txt`.

## Para compilar una APK firmada

1. Copia a `PikuClon/tools/firma/`:
   - `piku_release.keystore` (release)
   - `piku_debug.keystore` (debug)
2. Rellena en `PikuClon/export_presets.cfg`:
   ```
   keystore/debug_password="<contraseña debug>"
   keystore/release_password="<contraseña release>"
   ```
3. Exporta:
   ```
   godot --headless --path . --export-release "Android" PikuClon.apk
   ```
4. Si el exportador no firma, alinea y firma a mano:
   ```
   zipalign -f 4 PikuClon.apk alineado.apk
   apksigner sign --ks tools/firma/piku_release.keystore --ks-key-alias pikuclon \
     --out firmado.apk alineado.apk
   ```
5. **No subas** el keystore ni las contraseñas al repositorio.
