#!/bin/bash

cd $1

# - .tsv files have no stochastic content, may be md5sum-checked

echo ".tsv files:"
for f in *predictions.abridged*.tsv;do sort -k 1,2 $f | md5sum;done | sort -V
