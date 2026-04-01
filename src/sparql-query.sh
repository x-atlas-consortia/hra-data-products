#!/bin/bash
source constants.sh
shopt -s extglob
set -e

query=$1
output=$2

blazegraph-runner --journal=$BLAZEGRAPH_DB --outformat=json select $query $output.json
node "$(dirname "$0")/sparql-json2csv.js" $output.json $output
rm $output.json
