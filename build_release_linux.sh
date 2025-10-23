#!/bin/bash

flutterBin=flutter/bin/flutter

mkdir -p ./release

$flutterBin clean
$flutterBin build linux --target-platform linux-x64

# compress to release directory
tar -czf "release/enthusiast_tea_timer_linux.tar.gz" -C "build/linux/x64/release/bundle" .
