#!/usr/bin/bash

set -euo pipefail

step-cli certificate create \
    "$HOSTNAME Intermediate" "$HOSTNAME-intermediate.crt" "$HOSTNAME-intermediate".key \
    --profile intermediate-ca \
    --ca ./swsnr.crt --ca-key ./swsnr.key \
    --not-after=17532h # Valid for two years
