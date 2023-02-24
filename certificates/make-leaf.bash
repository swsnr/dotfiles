#!/usr/bin/bash

set -xeuo pipefail

subject="$1"
shift

mkdir -p leafs
# Leaf certs are valid for six months
step-cli certificate create \
    "$subject" "leafs/$subject".crt "leafs/$subject".key \
    --profile leaf \
    --ca "./$HOSTNAME-intermediate.crt" --ca-key "./$HOSTNAME-intermediate.key" \
    --not-after=4383h \
    "$@"
