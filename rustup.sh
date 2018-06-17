#!/bin/bash
rustup self update
rustup update

rustup default stable

CRATES=(
    cargo-update
    cargo-outdated
    cargo-release
    cargo-graph
    cargo-license
    xkpwgen
    tealdeer
)

for crate in ${CRATES}; do
    cargo install --force ${crate}
done

# Clippy needs nightly currrently
cargo +nightly install --force clippy
