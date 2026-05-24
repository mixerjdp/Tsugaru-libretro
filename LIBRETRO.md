# Tsugaru libretro

This branch keeps CaptainYS Tsugaru history as the base and layers the libretro core on top.

## Included libretro files

- `src/libretro/` contains the RetroArch core wrapper.
- `tsugaru_libretro.info` contains RetroArch metadata and supported extensions.
- `buildlibretro32.bat` builds the 32-bit Windows core.
- `buildlibretro64.bat` builds the 64-bit Windows core.
- `buildlinux.bat` builds the Linux core on the configured VM over SSH.

## Supported content

The libretro core accepts FM Towns floppy, disk, and CD images by extension:

```text
cue, bin, iso, mds, mdf, ccd, chd, d77, d88, rdd, img, fdi, hdm, h0, m3u
```

CHD support is provided through bundled `libchdr` under `src/externals/libchdr`.

## BIOS files

RetroArch system files should be placed under the RetroArch `system` directory, preferably:

```text
RetroArch/system/fmtowns/
```

Typical firmware names include:

```text
FMT_SYS.ROM
FMT_DOS.ROM
FMT_FNT.ROM
FMT_DIC.ROM
```

Firmware and commercial content are not redistributed by this repository.

## Local builds

Windows:

```bat
buildlibretro64.bat
buildlibretro32.bat
```

Linux VM:

```bat
buildlinux.bat
```

The Linux script expects SSH access to `juan@192.168.31.128` and builds with:

```text
cmake -S src -B build_linux -DBUILD_LIBRETRO_CORE=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON
```
