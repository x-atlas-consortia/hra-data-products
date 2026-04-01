#!/bin/bash
source constants.sh
shopt -s extglob
set -ev

DIR=$OUTPUT_DIR
JNL=$BLAZEGRAPH_DB
rm -f $JNL

tail -n +2 named-graphs.csv | \
while IFS=, read -r graph url _; do
  format="${url##*.}"

  echo $graph $url $format
  curl -s -L $url > graph.${format}
  blazegraph-runner load --journal=$JNL "--graph=${graph}" graph.${format}
done
