#!/bin/bash

flutterBin=~/Tools/flutter/bin/flutter

mkdir -p ./release
$flutterBin clean

$flutterBin build appbundle --flavor prod
$flutterBin build apk --flavor prod --split-per-abi
