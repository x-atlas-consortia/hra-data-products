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

# Disabled until we need to break out collections into component graphs loaded into the KG
# src/sparql-query.sh queries/reports/ad-hoc/component-graphs.rq component-graphs.csv
# tail -n +2 component-graphs.csv | \
# while IFS=, read -r graph url _; do
#   format="${url##*.}"

#   echo $graph $url $format
#   curl -s -L $url > graph.${format}
#   blazegraph-runner load --journal=$JNL "--graph=${graph}" graph.${format}
# done
# rm -f component-graphs.csv graph.ttl
