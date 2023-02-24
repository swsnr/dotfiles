#!/usr/bin/bash

set -euo pipefail

intermediate=intermediate-"$1"
subject="$2"
shift
shift

mkdir -p leafs
step-cli certificate create \
    "$subject" "leafs/$subject".crt "leafs/$subject".key \
    --profile leaf \
    --ca "./$intermediate.crt" --ca-key "./$intermediate.key" \
    --not-after=4383h \
    "${@}"
