#!/usr/bin/env bash

#rm -f build.zig chip.zig wokwi_api.zig *.log
#rm -rf dist
fd --exclude logs --exclude artifacts --exclude AGENTS.md --exclude justfile --exclude components --exclude esphome --exclude feedback --exclude "prompt*.txt" --exclude "*.sh" -x rm -rf 

