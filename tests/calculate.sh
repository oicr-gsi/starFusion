#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

cd $1

# - .tsv files have no stochastic content, may be md5sum-checked

echo ".tsv files:"
for f in *.tsv;do md5sum $f;done | sort -V

