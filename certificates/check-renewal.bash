#!/usr/bin/bash

set -euo pipefail

for certificate in **/*.crt; do
    if step-cli certificate needs-renewal "$certificate"; then
        echo "$certificate"
    fi
done
