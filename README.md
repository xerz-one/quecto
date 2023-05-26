# Quecto

![Public domain][CC0]

A Linux distribution aimed at being as tiny as possible

## Get started

To build an image of Quecto, all you need is a Nix setup with flakes support
on which to run the following:
```sh
nix build git+https://codeberg.org/xerz/quecto#quecto
```

Yep, that's it. You can then proceed to test the finalized image with e.g.:
```sh
qemu-system-i386 -accel kvm -m 2G -cdrom result/iso/nixos.iso
```

## Goals

- Live ISO for read-only and read-write media
- Supports i686 systems, either BIOS or UEFI
- Old school desktop environment
    - CDE is currently the window manager of choice
- Features a web browser and a terminal emulator
    - Firefox is the end goal, currently testing with Netsurf
    - Might end up adding something else, a drawing app or something
- Optimized as much as reasonable
    - Targeting Pentium III for minimum system requirements
    - Should be able to fit within a 140MB MD Data

[CC0]: https://licensebuttons.net/p/zero/1.0/80x15.png
