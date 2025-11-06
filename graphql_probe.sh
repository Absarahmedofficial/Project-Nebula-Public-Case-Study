#!/usr/bin/env bash
set -euo pipefail
: "${SAFE_MODE:=1}"
: "${TARGET_GQL:=https://example.lab/graphql/v1}"


curl -s -H "Content-Type: application/json" \
-d '{"query":"{ __typename }"}' "$TARGET_GQL" | jq .
