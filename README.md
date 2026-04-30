# Tsugaru libretro

Tsugaru libretro es un fork de **Tsugaru**, el emulador de FM Towns / FM Towns Marty de CaptainYS, adaptado para usarse como core de **RetroArch / libretro**.

El objetivo de este fork es ofrecer un core eficiente, estable y facil de instalar para ejecutar contenido de FM Towns desde RetroArch, usando el backend de Tsugaru como base y evitando redistribuir BIOS o ROMs propietarias.

## Que incluye este proyecto

- Core libretro para FM Towns.
- Soporte para contenido CD y floppy segun extension.
- Archivo `.info` para RetroArch.
- Scripts de compilacion para 32 bits y 64 bits.

## Que no incluye

- BIOS o ROMs del sistema.
- Contenido comercial del usuario.
- Paquetes de software de terceros no redistribuibles.

## Requisitos

Para usar el core necesitas:

- RetroArch instalado.
- El core `tsugaru_libretro.dll` correspondiente a tu arquitectura.
- El archivo `tsugaru_libretro.info`.
- BIOS / ROMs legales del sistema FM Towns.

## Instalacion del core

### 64 bits

Copiar:

```text
tsugaru_libretro.dll
```

en:

```text
D:\Emulation\Emulators\RetroArch\cores\
```

### 32 bits

Si usas una instalacion de RetroArch de 32 bits, copia el mismo archivo compilado para Win32 dentro de la carpeta `cores` de esa instalacion.

## Instalacion del archivo .info

Copiar:

```text
tsugaru_libretro.info
```

en:

```text
D:\Emulation\Emulators\RetroArch\info\
```

RetroArch usa este archivo para mostrar el nombre correcto del core y para reconocer sus extensiones compatibles.

## Instalacion de BIOS y ROMs del sistema

El core busca los archivos de sistema en la carpeta `system` de RetroArch. La ruta recomendada es:

```text
D:\Emulation\Emulators\RetroArch\system\fmtowns\
```

Si esa subcarpeta no existe, el core tambien puede caer a `system` directamente, pero la ruta recomendada es `system\\fmtowns`.

Archivos tipicos de BIOS / ROM del sistema:

```text
FMT_SYS.ROM
FMT_DOS.ROM
FMT_FNT.ROM
FMT_DIC.ROM
```

Los nombres exactos pueden variar segun el set de ROMs compatible que uses, pero la idea es la misma: mantener los firmwares en `system`, no dentro de `cores`.

## Contenido soportado

El core acepta medios de CD y floppy por extension. Las extensiones soportadas actualmente incluyen:

```text
cue, bin, iso, mds, mdf, ccd, chd, d77, d88, rdd, img, fdi, hdm, h0, m3u
```

Notas:

- Para CD, el core monta medios como `cue`, `bin`, `iso`, `mds`, `mdf`, `ccd` y `chd`.
- Para floppy, acepta `d77`, `d88`, `rdd`, `img`, `fdi`, `hdm` y `h0`.
- `m3u` puede usarse para listas de medios segun el flujo que maneje RetroArch.

## Como ejecutar

1. Abre RetroArch.
2. Carga el core `Tsugaru`.
3. Carga un contenido compatible.
4. Si el juego necesita BIOS, verifica que los archivos esten en `system\\fmtowns`.

## Compilacion local

Para compilar el core desde este repositorio:

```bat
buildlibretro32.bat
buildlibretro64.bat
```

El script de 64 bits copia el DLL resultante a la carpeta `cores` de RetroArch.

## Release v1.00

La release `v1.00` publica solo estos archivos:

- `tsugaru_libretro_32bit.dll`
- `tsugaru_libretro_64bit.dll`
- `tsugaru_libretro.info`

No se incluyen BIOS en la release.

## Agradecimientos

- CaptainYS y los contribuidores de Tsugaru.
- La comunidad de libretro por la documentacion y el ecosistema de cores.

