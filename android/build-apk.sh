#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

classes_dex=${1:-"$repo_root/build/android/classes.dex"}
native_library=${2:-"$repo_root/build/android/libpauli.so"}
output=${3:-"$repo_root/build/android/pauli.apk"}

abi=${ANDROID_ABI:-armeabi-v7a}
compile_sdk=${ANDROID_COMPILE_SDK:-36}

case "$abi" in
    armeabi-v7a|arm64-v8a|x86|x86_64) ;;
    *)
        printf 'unsupported Android ABI: %s\n' "$abi" >&2
        exit 1
        ;;
esac

[[ -f $classes_dex ]] || {
    printf 'missing direct classes.dex: %s\n' "$classes_dex" >&2
    exit 1
}
[[ -f $native_library ]] || {
    printf 'missing native library: %s\n' "$native_library" >&2
    exit 1
}

android_home=${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}
[[ -n $android_home ]] || {
    echo 'ANDROID_HOME or ANDROID_SDK_ROOT is required' >&2
    exit 1
}

build_tools=${ANDROID_BUILD_TOOLS:-}
if [[ -z $build_tools ]]; then
    build_tools=$(
        find "$android_home/build-tools" \
            -mindepth 1 -maxdepth 1 -type d |
            sort -V |
            tail -n 1
    )
fi

aapt2="$build_tools/aapt2"
zipalign="$build_tools/zipalign"
apksigner="$build_tools/apksigner"
android_jar="$android_home/platforms/android-$compile_sdk/android.jar"

for required in "$aapt2" "$zipalign" "$apksigner" "$android_jar"; do
    [[ -e $required ]] || {
        printf 'missing Android packaging input: %s\n' "$required" >&2
        exit 1
    }
done

work="$repo_root/build/android/apk-work-$abi"
rm -rf "$work"
mkdir -p "$work/lib/$abi" "$(dirname -- "$output")"

cp "$native_library" "$work/lib/$abi/libpauli.so"

manifest_apk="$work/manifest.apk"
unaligned="$work/unaligned.apk"
aligned="$work/aligned.apk"

"$aapt2" link \
    -I "$android_jar" \
    --manifest "$repo_root/android/AndroidManifest.xml" \
    --min-sdk-version 21 \
    --target-sdk-version 36 \
    -o "$manifest_apk"

cp "$manifest_apk" "$unaligned"
zip -q -j "$unaligned" "$classes_dex"
(
    cd "$work"
    zip -q -u "$unaligned" "lib/$abi/libpauli.so"
)

# The sideload manifest extracts the compressed .so at install time.
# ELF load-segment alignment is handled by build-native.sh.
"$zipalign" -f 4 "$unaligned" "$aligned"

keystore=${PAULI_KEYSTORE:-"$HOME/.config/pauli/debug.keystore"}
key_alias=${PAULI_KEY_ALIAS:-androiddebugkey}
key_password=${PAULI_KEY_PASSWORD:-android}

if [[ ! -f $keystore ]]; then
    mkdir -p "$(dirname -- "$keystore")"
    chmod 700 "$(dirname -- "$keystore")"

    keytool -genkeypair -noprompt \
        -keystore "$keystore" \
        -storepass "$key_password" \
        -keypass "$key_password" \
        -alias "$key_alias" \
        -dname 'CN=Pauli Debug,O=Pauli,C=US' \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 >/dev/null 2>&1
fi

"$apksigner" sign \
    --ks "$keystore" \
    --ks-pass "pass:$key_password" \
    --key-pass "pass:$key_password" \
    --ks-key-alias "$key_alias" \
    --out "$output" \
    "$aligned"

"$apksigner" verify --verbose "$output"

printf 'APK ABI                 %s\n' "$abi"
printf 'APK target API          %s\n' 36
printf 'APK                     %s\n' "$output"
printf 'signing key             %s\n' "$keystore"
