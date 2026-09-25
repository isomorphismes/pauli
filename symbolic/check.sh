#!/bin/sh
set -eu

script_dir=$(
    CDPATH= cd -- "$(dirname -- "$0")"
    pwd
)
repo_root=$(
    CDPATH= cd -- "$script_dir/.."
    pwd
)
cd "$repo_root"

green='\033[32m'
red='\033[31m'
reset='\033[0m'

temporary_directory=$(
    mktemp -d
)
trap 'rm -rf "$temporary_directory"' EXIT INT TERM

run_sage_python() {
    script_path=$1

    if command -v sage >/dev/null 2>&1; then
        sage -python "$script_path"
        return
    fi

    if command -v docker >/dev/null 2>&1; then
        docker run --rm \
            -v "$repo_root:/work:ro" \
            -w /work \
            sagemath/sagemath:10.8 \
            sage -python "$script_path"
        return
    fi

    if command -v podman >/dev/null 2>&1; then
        podman run --rm \
            -v "$repo_root:/work:ro" \
            -w /work \
            docker.io/sagemath/sagemath:10.8 \
            sage -python "$script_path"
        return
    fi

    printf \
        '%bFAIL%b: SageMath, Docker, or Podman is required.\n' \
        "$red" \
        "$reset" \
        >&2
    exit 1
}

run_sage_python \
    symbolic/check_hydrogen_states.py

run_sage_python \
    symbolic/check_with_sympy.py

run_sage_python \
    symbolic/export_f64.py \
    > "$temporary_directory/hydrogen_spdf_f64.h"

run_sage_python \
    symbolic/export_f64_receipts.py \
    > "$temporary_directory/f64_receipts.tsv"

if ! command -v cc >/dev/null 2>&1; then
    printf \
        '%bFAIL%b: a C99 compiler is required for the F64 receipt check.\n' \
        "$red" \
        "$reset" \
        >&2
    exit 1
fi

cc \
    -std=c99 \
    -O2 \
    -Wall \
    -Wextra \
    -pedantic \
    -I "$temporary_directory" \
    symbolic/check_f64_runtime.c \
    -lm \
    -o "$temporary_directory/check_f64_runtime"

"$temporary_directory/check_f64_runtime" \
    "$temporary_directory/f64_receipts.tsv"

printf \
    '%bPASS%b: symbolic and Complex F64 checks complete.\n' \
    "$green" \
    "$reset"
