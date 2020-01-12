#!/bin/bash

for i in ./*.wav ; do
    current_file="$(basename "$i" .wav).raw.u8"
    echo "$current_file"
    sox "$i" -r 16000 -b 8 -c 1 "$current_file"
    node filter.js "$current_file"
    rm "$current_file"
done
