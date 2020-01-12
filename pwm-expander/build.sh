#!/bin/sh

avr-gcc -g -Os -mmcu=attiny13a -c hello-world.c
avr-gcc -g -mmcu=attiny13a -o hello-world.elf hello-world.o