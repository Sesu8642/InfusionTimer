#!/bin/bash

flutterBin=flutter/bin/flutter

mkdir -p ./release
$flutterBin clean

$flutterBin build web --release
