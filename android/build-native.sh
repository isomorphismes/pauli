#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

output=${1:-"$repo_root/build/android/libpauli.so"}
if (($# > 0)); then
    shift
fi

renderer_sources=("$@")
generated_directory=${PAULI_GENERATED_DIRECTORY:-"$repo_root/build/generated"}
if ((${#renderer_sources[@]} == 0)); then
    [[ -s "$generated_directory/hydrogen_spdf_f64.h" ]] || {
        echo 'missing checked hydrogen build input; run the declared hydrogen-f64 generation stage' >&2
        exit 1
    }
    (cd "$repo_root" && sha256sum --check "$generated_directory/sources.sha256")
    renderer_sources=(
        "$repo_root/android/native/pauli_renderer_orbitals.c"
        "$repo_root/android/native/pauli_orbital.c"
        "$repo_root/android/native/pauli_color.c"
        "$repo_root/android/native/pauli_volume_image.c"
        "$repo_root/android/native/pauli_gles_image.c"
    )
fi

abi=${ANDROID_ABI:-armeabi-v7a}
api=${ANDROID_API:-21}

case "$abi" in
    armeabi-v7a) target=armv7a-linux-androideabi ;;
    arm64-v8a) target=aarch64-linux-android ;;
    x86) target=i686-linux-android ;;
    x86_64) target=x86_64-linux-android ;;
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

clang="$toolchain/bin/${target}${api}-clang"
readelf="$toolchain/bin/llvm-readelf"
glue_dir="$ndk/sources/android/native_app_glue"
glue_source="$glue_dir/android_native_app_glue.c"

for required in "$clang" "$readelf" "$glue_source"; do
    [[ -e $required ]] || {
        printf 'missing Android build input: %s\n' "$required" >&2
        exit 1
    }
done

mkdir -p "$(dirname -- "$output")"

# NDK-owned glue retains unused callback parameters. Keep that allowance
# separate from Pauli's sources, which compile with warnings as errors.
glue_object="${output%.so}.native-app-glue.o"
"$clang" -std=c11 -O2 -fPIC -Wall -Wextra -Werror \
    -Wno-unused-parameter -I "$glue_dir" \
    -c "$glue_source" -o "$glue_object"

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
    -std=c11 \
    -O2 \
    -fPIC \
    -shared \
    -Wall \
    -Wextra \
    -Werror \
    -I "$glue_dir" \
    -I "$repo_root/android/native" \
    -I "$generated_directory" \
    "$repo_root/android/native/pauli_android.c" \
    "$glue_object" \
    "${renderer_sources[@]}" \
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

printf 'native ABI              %s\n' "$abi"
printf 'native API floor        %s\n' "$api"
printf 'native library          %s\n' "$output"
