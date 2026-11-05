#!/bin/bash
echo "LANG=$LANG LANGUAGE=$LANGUAGE LC_ALL=$LC_ALL LC_COLLATE=$LC_COLLATE charmap=$(locale charmap)" >&2
locale | grep -E 'LC_COLLATE|LC_ALL|LANG' >&2

cd $1

# - .tsv files have no stochastic content, may be md5sum-checked

echo ".tsv files:"
for f in *predictions.abridged*.tsv;do sort -k 1,2 $f | md5sum;done | sort -V
