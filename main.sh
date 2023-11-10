#!/bin/bash

mode=1
gcc -nostartfiles -nodefaultlibs -o smart.elf smart.c
nasm -f bin build/for.asm -o renos/x.bin -O 3
if [ ! -d "renos" ]; then
  echo "renos folder does not exist"
  exit 1
fi

if [ "$mode" -eq 1 ]; then
 rm renos/bootloader.bin
  sleep 1
  nasm -f bin build/boot.asm -o renos/bootloader.bin -O 0
  nasm -f bin build/OS.asm -o renos/OS.bin -O 0
  echo "•modifying code"
  sleep 3
  
objcopy -O renos/binary smart.elf renos/smart.bin
fi



kill nasm
  rm boot.iso
sleep 1
genisoimage -o boot.iso -b x.bin -no-emul-boot -boot-load-size 4 -boot-info-table -quiet renos
nasm build/boot.asm -l file.lst
echo "•compiled!"

if [ "$mode" -eq 0 ]; then
  qemu-system-x86_64 -cdrom boot.iso
fi

if [ "$mode" -eq 1 ]; then
  echo "•testing"
  qemu-system-x86_64 -cdrom boot.iso
fi