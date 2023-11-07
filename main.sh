#!/bin/bash

mode=1
gcc -nostartfiles -nodefaultlibs -o smart.elf smart.c
if [ ! -d "renos" ]; then
  echo "renos folder does not exist"
  exit 1
fi

if [ "$mode" -eq 1 ]; then
 rm renos/bootloader.bin
  sleep 1
  nasm -f bin renos/boot.asm -o renos/bootloader.bin
  echo "•modifying code"
  sleep 2
  
objcopy -O renos/binary smart.elf renos/smart.bin
fi



if [ "$mode" -eq 1 ]; then
  rm boot.iso
sleep 5
mkisofs -o boot.iso -b bootloader.bin -no-emul-boot -boot-load-size 4 -boot-info-table -quiet -data-change-warn  renos

echo "•compiled!"
fi
if [ "$mode" -eq 0 ]; then
  qemu-system-x86_64 -cdrom boot.iso
fi
if [ "$mode" -eq 1 ]; then
  echo "•testing"
  qemu-system-x86_64 -cdrom boot.iso
fi