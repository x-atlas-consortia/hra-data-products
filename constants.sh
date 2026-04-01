export DEFAULT_PURL_IRI="https://purl.humanatlas.io/"
export DEFAULT_LOD_IRI="https://lod.humanatlas.io/"
export DEFAULT_CDN_IRI="https://cdn.humanatlas.io/digital-objects/"
export CDN_S3_BUCKET="s3://cdn-humanatlas-io/data-products/"

export BLAZEGRAPH_DB="blazegraph.jnl"
export OUTPUT_DIR="docs"
export VERSION="draft"

if [ -e "env.sh" ]; then
  source env.sh
fi

if [ "$(which do-processor)" ==  "" ]; then
  if [ -e "../hra-do-processor/.venv/bin/activate" ]; then
    source  ../hra-do-processor/.venv/bin/activate
  else
    alias do-processor=./src/do-processor.sh
  fi
fi
