#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
backend=${IDRIC_DEX_REPO:-}
idric=${IDRIC:-idris2}

[[ -n $backend && -d $backend ]] || {
    echo 'IDRIC_DEX_REPO must point to a checkout of dilapidated-shed/idric-arm-thumb' >&2
    exit 1
}

runtime_library=${IDRIC_RUNTIME_LIBRARY:-"$(dirname -- "$idric")/idris2_app/libidris2_support.so"}
[[ -f $runtime_library ]] || {
    printf 'missing Idriç host runtime library: %s\n' "$runtime_library" >&2
    exit 1
}

(
    cd "$backend"
    "$idric" --build wegert-dex.ipkg
)

mkdir -p "$repo_root/build/android"

IDRIS2_PATH="$backend/build/ttc:${IDRIS2_PATH:-}" \
    "$idric" \
    --source-dir "$repo_root/android" \
    "$repo_root/android/PauliActivityShellGen.idr" \
    -o pauli-activity-shell-gen

generator="$repo_root/build/exec/pauli-activity-shell-gen"
cp "$runtime_library" "${generator}_app/"

run_generator() {
    (
        cd "$repo_root"
        LD_LIBRARY_PATH="$(dirname -- "$runtime_library"):${LD_LIBRARY_PATH:-}" \
            "$generator"
    )
}

run_generator
cp "$repo_root/build/android/classes.dex" \
    "$repo_root/build/android/classes-first.dex"
run_generator
cmp "$repo_root/build/android/classes-first.dex" \
    "$repo_root/build/android/classes.dex"

python3 "$backend/tests/dex/check_dex.py" \
    "$repo_root/build/android/classes.dex"

printf 'DEX backend SHA          %s\n' "$(git -C "$backend" rev-parse HEAD)"
printf 'classes.dex SHA-256      %s\n' \
    "$(sha256sum "$repo_root/build/android/classes.dex" | cut -d' ' -f1)"
