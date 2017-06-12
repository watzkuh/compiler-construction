#!/bin/bash
FILES=./test/samplefiles/*

for f in $FILES
do
  echo "Processing $f file..."
  # take action on each file. $f store current file name
  ./go $f
done
