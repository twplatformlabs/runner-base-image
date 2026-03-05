#!/usr/bin/env bash
set -eo pipefail

# Usage: bash from-manifest.sh TYPE IMAGE
#   type: provenance | sbom
#   image: registry path to image:tag
#
# Will output either sbom or provenance from image manifest to stdout
echo "Pulling ${1} from ${2} manifest"
type="${1}"
image_ref="${2}"

# Obtain manifest index digest
digest=$(oras manifest fetch --descriptor "${image_ref}" | jq -r '.digest')
if [[ -z "$digest" ]]; then
  echo "❌ Unable to resolve digest for ${image_ref}"
  exit 1
fi
digest_ref="${image_ref%@*}@${digest}"
echo "Digest reference: ${digest_ref}"
TMP_DIR=$(mktemp -d)
oras copy "$digest_ref" --to-oci-layout "$TMP_DIR"
# get an SBOM for each target
for BLOB in "$TMP_DIR"/blobs/sha256/*; do
  if jq -e . "$BLOB" >/dev/null 2>&1; then
    PREDICATE=$(jq -r '.predicateType // empty' "$BLOB")
    if [[ "$PREDICATE" == "https://spdx.dev/Document"  && "$type" == "sbom" ]]; then
        cat "$BLOB" | jq .
        break
    elif [[ "$PREDICATE" == "https://slsa.dev/provenance/v1"  && "$type" == "provenance" ]]; then
        cat "$BLOB" | jq .
        break
    fi
  fi
done