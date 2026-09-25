#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
cd "$repo_root"

green='\033[32m'
red='\033[31m'
reset='\033[0m'

run_checks() {
    sage symbolic/check_hydrogen_states.sage
    sage -python symbolic/check_with_sympy.py
}

if command -v sage >/dev/null 2>&1; then
    run_checks
elif command -v docker >/dev/null 2>&1; then
    docker run --rm \
        -v "$repo_root:/work" \
        -w /work \
        sagemath/sagemath:10.8 \
        sh -lc 'sage symbolic/check_hydrogen_states.sage && sage -python symbolic/check_with_sympy.py'
elif command -v podman >/dev/null 2>&1; then
    podman run --rm \
        -v "$repo_root:/work" \
        -w /work \
        docker.io/sagemath/sagemath:10.8 \
        sh -lc 'sage symbolic/check_hydrogen_states.sage && sage -python symbolic/check_with_sympy.py'
else
    printf '%bFAIL%b: SageMath, Docker, or Podman is required.\n' "$red" "$reset" >&2
    exit 1
fi

printf '%bPASS%b: symbolic checks complete.\n' "$green" "$reset"
