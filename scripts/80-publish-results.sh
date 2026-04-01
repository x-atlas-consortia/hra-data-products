#!/bin/bash
source constants.sh
shopt -s extglob
set -ev

OUT=$OUTPUT_DIR

mkdir -p $OUTPUT_DIR
cp -r site/* $OUTPUT_DIR

node src/gen-report-markdown.js $OUT/REPORTS.md queries/reports $OUT/reports

CREATION_DATE=$(date)
echo "$CREATION_DATE" > $OUT/CREATION_DATE

node src/gen-readme.js $VERSION "$CREATION_DATE" $OUT/README.md
