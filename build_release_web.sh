#!/bin/bash

flutterBin=flutter/bin/flutter

mkdir -p ./release
$flutterBin clean

$flutterBin build web --release

# compress to release directory
tar -czf "release/enthusiast_tea_timer_web.tar.gz" -C "build/web" .
