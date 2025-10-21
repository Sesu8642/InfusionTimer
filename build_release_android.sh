#!/bin/bash

flutterBin=flutter/bin/flutter

mkdir -p ./release
$flutterBin clean

$flutterBin build appbundle --release
$flutterBin build apk --release --split-per-abi
$flutterBin build apk --release
