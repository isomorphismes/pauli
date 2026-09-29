#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
work=${TMPDIR:-/tmp}/pauli-basic-d-check
rm -rf "$work"
mkdir -p "$work"

cc -std=c11 -O2 -ffunction-sections -fdata-sections \
    -I"$repo_root/d/basic/reference_include" \
    -I"$repo_root/android/native" \
    -Wl,--gc-sections \
    "$repo_root/d/basic/reference_check.c" \
    -lm \
    -o "$work/reference-check"
"$work/reference-check"

gdc -O2 \
    -I"$repo_root/d/basic" \
    "$repo_root/d/basic/check.d" \
    "$repo_root/d/basic/pauli_orbitals.d" \
    -o "$work/d-check"
"$work/d-check"

gdc -O2 -c \
    -I"$repo_root/d/basic" \
    "$repo_root/d/basic/pauli_renderer.d" \
    -o "$work/pauli_renderer.o"

echo "PASS: D basic Pauli core, receipts, and GLES2 wrapper compile"
