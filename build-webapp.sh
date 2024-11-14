#!/bin/bash

PKG_DIR="./apps/namadillo"
OUTPUT_DIR="${PKG_DIR}/dist"
DEST_DIR=${1:-/data}

if [[ -d "$DEST_DIR" ]]; then
  echo "${DEST_DIR} already exists." 1>&2
  exit 1
fi

echo "namada interface test"

# from docs, ubuntu setup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add wasm32-unknown-unknown
sudo apt-get install -y clang
sudo apt-get install -y pkg-config
sudo apt-get install -y libssl-dev
sudo apt-get install -y protobuf-compiler
sudo apt-get install -y curl
sudo apt-get install -y npm
curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh

yarn || exit 1
yarn prepare || exit 1

yarn --cwd ${PKG_DIR} wasm:build || exit 1
yarn --cwd ${PKG_DIR} build || exit 1

if [[ ! -d "$OUTPUT_DIR" ]]; then
  echo "Missing output directory: $OUTPUT_DIR" 1>&2
  exit 1
fi

mv "$OUTPUT_DIR" "$DEST_DIR"
