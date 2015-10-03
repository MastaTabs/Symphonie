#!/bin/sh
vc +aos68k -c99 -c libs.c -o libs.o
vasmm68k_mot -m68020 -phxass -Fhunk -I ~/build/amiga/ndk_39/include/include_i/ -o Symphonie\ Pro.o Symphonie\ Source.Assembler
vlink -L$VBCC/targets/m68k-amigaos/lib -lamiga -o Symphonie\ Pro Symphonie\ Pro.o libs.o
#vasmm68k_mot -linedebug -m68020 -phxass -Fhunkexe -I ~/build/amiga/ndk_39/include/include_i/ -o Symphonie\ Pro Symphonie\ Source.Assembler
