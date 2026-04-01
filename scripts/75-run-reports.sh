#!/bin/bash
source constants.sh
shopt -s extglob
set -ev

DIR=$OUTPUT_DIR/reports
FILTER="$1"

mkdir -p $DIR
node ./src/run-reports-blazegraph.js $BLAZEGRAPH_DB $DIR $FILTER
