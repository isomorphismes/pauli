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
    armeabi-v7a)
        target=armv7a-linux-androideabi
        ick_target=arm-linux-gnueabi
        header_target=arm-linux-androideabi
        ick_flags=(-march=armv7-a -mthumb -mfpu=neon -mfloat-abi=softfp)
        ;;
    arm64-v8a)
        target=aarch64-linux-android
        ick_target=aarch64-linux-gnu
        header_target=aarch64-linux-android
        ick_flags=(-ffixed-x18)
        ;;
    x86)
        target=i686-linux-android
        ick_target=i686-linux-gnu
        header_target=i686-linux-android
        ick_flags=(-march=i686 -mssse3 -mfpmath=sse -mstackrealign)
        ;;
    x86_64)
        target=x86_64-linux-android
        ick_target=x86_64-linux-gnu
        header_target=x86_64-linux-android
        ick_flags=(-march=x86-64-v2 -mno-avx -mno-movbe)
        ;;
    *)
        printf 'unsupported Android ABI: %s\n' "$abi" >&2
        exit 1
        ;;
esac

ick=${ICK_CC:-${ICK_ROOT:+$ICK_ROOT/bin/${ick_target}-gcc}}
[[ -n $ick && -x $ick ]] || {
    printf 'ICK compiler is required; set ICK_CC or ICK_ROOT for %s.\n' "$ick_target" >&2
    exit 1
}
[[ $("$ick" -dumpmachine) == "$ick_target" ]] || {
    printf 'ICK compiler does not target %s.\n' "$ick_target" >&2
    exit 1
}

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

owned_objects=()
builtin_include=$("$ick" -print-file-name=include)
[[ -d $builtin_include ]] || {
    printf 'ICK builtin headers are missing: %s\n' "$builtin_include" >&2
    exit 1
}
for source in "$repo_root/android/native/pauli_android.c" "${renderer_sources[@]}"; do
    object="${output%.so}.$(basename -- "${source%.c}").o"
    "$ick" "${ick_flags[@]}" -std=c11 -O2 -fPIC -Wall -Wextra -Werror \
        -nostdinc -isystem "$builtin_include" \
        --sysroot="$toolchain/sysroot" \
        -isystem "$toolchain/sysroot/usr/include" \
        -isystem "$toolchain/sysroot/usr/include/$header_target" \
        -D__ANDROID__ -D__ANDROID_API__="$api" -D__ANDROID_MIN_SDK_VERSION__="$api" \
        -DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD \
        -I "$glue_dir" -I "$repo_root/android/native" -I "$generated_directory" \
        -S "$source" -o "$object.s"
    "$clang" "${ick_flags[@]}" -c "$object.s" -o "$object"
    owned_objects+=("$object")
done

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
    "$glue_object" \
    "${owned_objects[@]}" \
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
printf 'owned C frontend        %s\n' "$ick"
printf 'NDK glue/assembly/link  %s\n' "$clang"
printf 'native library          %s\n' "$output"
