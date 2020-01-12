#!/bin/sh

arduino_dist=/Applications/Arduino.app/Contents/Java/hardware/tools/avr/

./build.sh
avr-objcopy -j .text -j .data -O ihex hello-world.elf hello-world.hex
${arduino_dist}bin/avrdude -C ${arduino_dist}/etc/avrdude.conf -p t13 -P /dev/cu.usbmodem14201 -c avrisp -b 19200 -v -U flash:w:hello-world.hex