#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
abi=${ANDROID_ABI:-armeabi-v7a}

library="$repo_root/build/android/libpauli.so"
apk="$repo_root/build/android/pauli-d-$abi.apk"

ANDROID_ABI="$abi" \
    bash "$repo_root/android/build-native-d.sh" \
    "$library"

ANDROID_ABI="$abi" \
    bash "$repo_root/android/build-apk.sh" \
    "$library" \
    "$apk"

sha256sum "$apk"
