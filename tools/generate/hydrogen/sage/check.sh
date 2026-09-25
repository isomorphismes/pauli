#!/bin/sh
set -eu

script_dir=$(
    CDPATH= cd -- "$(dirname -- "$0")"
    pwd
)
repo_root=$(
    CDPATH= cd -- "$script_dir/../../../.."
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

sage_directory=tools/generate/hydrogen/sage

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

run_sage_python "$sage_directory/check_hydrogen_states.py"
run_sage_python "$sage_directory/check_with_sympy.py"
run_sage_python "$sage_directory/update_public.py"
run_sage_python "$sage_directory/check_notebook.py"

if ! git diff --exit-code -- hydrogen.html books.html
then
    printf \
        '%bFAIL%b: public hydrogen HTML is stale. Regenerate it with Sage.\n' \
        "$red" \
        "$reset" \
        >&2
    exit 1
fi

run_sage_python "$sage_directory/export_polar_f64.py" \
    > "$temporary_directory/hydrogen_spdf_f64.h"

run_sage_python "$sage_directory/export_polar_f64_receipts.py" \
    > "$temporary_directory/polar_f64_receipts.tsv"

if grep -Eq \
    '(hypot|atan2|\.real|\.imaginary)' \
    "$temporary_directory/hydrogen_spdf_f64.h"
then
    printf \
        '%bFAIL%b: generated runtime evaluator contains rectangular complex machinery.\n' \
        "$red" \
        "$reset" \
        >&2
    exit 1
fi

if ! command -v cc >/dev/null 2>&1; then
    printf \
        '%bFAIL%b: a C99 compiler is required for the polar F64 receipt check.\n' \
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
    "$sage_directory/check_polar_f64_runtime.c" \
    -lm \
    -o "$temporary_directory/check_polar_f64_runtime"

"$temporary_directory/check_polar_f64_runtime" \
    "$temporary_directory/polar_f64_receipts.tsv"

printf \
    '%bPASS%b: hydrogen derivation, public artifacts, and polar runtime checks complete.\n' \
    "$green" \
    "$reset"
