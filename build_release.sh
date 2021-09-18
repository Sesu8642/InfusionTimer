#!/bin/bash

flutterBin="~/Tools/flutter/bin/flutter"

mkdir -p ./release

$flutterBin build appbundle
$flutterBin build apk --split-per-abi
