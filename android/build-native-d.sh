#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

output=${1:-"$repo_root/build/android/libpauli-d.so"}
abi=${ANDROID_ABI:-armeabi-v7a}
api=${ANDROID_API:-21}
ldc=${LDC:-ldc2}

command -v "$ldc" >/dev/null 2>&1 || {
    printf 'LDC not found: %s\n' "$ldc" >&2
    exit 1
}

case "$abi" in
    armeabi-v7a)
        clang_target=armv7a-linux-androideabi
        ldc_triple=armv7a-linux-androideabi"$api"
        ;;
    arm64-v8a)
        clang_target=aarch64-linux-android
        ldc_triple=aarch64-linux-android"$api"
        ;;
    x86)
        clang_target=i686-linux-android
        ldc_triple=i686-linux-android"$api"
        ;;
    x86_64)
        clang_target=x86_64-linux-android
        ldc_triple=x86_64-linux-android"$api"
        ;;
    *)
        printf 'unsupported Android ABI: %s\n' "$abi" >&2
        exit 1
        ;;
esac

ndk=${ANDROID_NDK_HOME:-${ANDROID_NDK_ROOT:-}}
if [[ -z $ndk ]]; then
    android_home=${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}
    [[ -n $android_home ]] || {
        echo 'ANDROID_NDK_HOME or ANDROID_HOME is required' >&2
        exit 1
    }

    ndk=$(
        find "$android_home/ndk" \
            -mindepth 1 -maxdepth 1 -type d 2>/dev/null |
            sort -V |
            tail -n 1
    )
fi

[[ -d $ndk ]] || {
    printf 'Android NDK not found: %s\n' "$ndk" >&2
    exit 1
}

toolchain=$(
    find "$ndk/toolchains/llvm/prebuilt" \
        -mindepth 1 -maxdepth 1 -type d |
        head -n 1
)

[[ -n $toolchain ]] || {
    echo 'Android NDK LLVM toolchain not found' >&2
    exit 1
}

clang="$toolchain/bin/${clang_target}${api}-clang"
readelf="$toolchain/bin/llvm-readelf"
glue_dir="$ndk/sources/android/native_app_glue"
glue_source="$glue_dir/android_native_app_glue.c"

for required in "$clang" "$readelf" "$glue_source"; do
    [[ -e $required ]] || {
        printf 'missing Android build input: %s\n' "$required" >&2
        exit 1
    }
done

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

d_flags=(
    -betterC
    -O3
    -release
    -boundscheck=off
    -relocation-model=pic
    "-mtriple=$ldc_triple"
    "-I=$repo_root/d/basic"
)

"$ldc" "${d_flags[@]}" -c \
    "$repo_root/d/basic/pauli_orbitals.d" \
    -of="$work/pauli_orbitals.o"

"$ldc" "${d_flags[@]}" -c \
    "$repo_root/d/basic/pauli_renderer.d" \
    -of="$work/pauli_renderer.o"

"$ldc" "${d_flags[@]}" -c \
    "$repo_root/d/basic/pauli_android.d" \
    -of="$work/pauli_android.o"

"$clang" \
    -std=c11 \
    -O2 \
    -fPIC \
    -I "$glue_dir" \
    -c "$glue_source" \
    -o "$work/android_native_app_glue.o"

"$clang" \
    -std=c11 \
    -O2 \
    -fPIC \
    -I "$glue_dir" \
    -c "$repo_root/d/basic/android_app_bridge.c" \
    -o "$work/android_app_bridge.o"

mkdir -p "$(dirname -- "$output")"

link_alignment=()
case "$abi" in
    arm64-v8a|x86_64)
        link_alignment=(
            -Wl,-z,max-page-size=16384
            -Wl,-z,common-page-size=16384
        )
        ;;
esac

"$clang" \
    -shared \
    "$work/pauli_orbitals.o" \
    "$work/pauli_renderer.o" \
    "$work/pauli_android.o" \
    "$work/android_native_app_glue.o" \
    "$work/android_app_bridge.o" \
    -Wl,--no-undefined \
    -Wl,-soname,libpauli.so \
    "${link_alignment[@]}" \
    -landroid \
    -llog \
    -lEGL \
    -lGLESv3 \
    -lm \
    -o "$output"

symbols=$("$readelf" -Ws "$output")
grep -Fq 'ANativeActivity_onCreate' <<<"$symbols"
grep -Fq 'android_main' <<<"$symbols"
grep -Fq 'pauli_renderer_start' <<<"$symbols"

printf 'D native ABI            %s\n' "$abi"
printf 'D native API floor      %s\n' "$api"
printf 'D target triple         %s\n' "$ldc_triple"
printf 'D native library        %s\n' "$output"
