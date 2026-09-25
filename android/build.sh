#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
abi=${ANDROID_ABI:-armeabi-v7a}

ANDROID_ABI="$abi" \
    bash "$repo_root/android/build-native.sh" \
    "$repo_root/build/android/libpauli.so"

ANDROID_ABI="$abi" \
    bash "$repo_root/android/build-apk.sh" \
    "$repo_root/build/android/libpauli.so" \
    "$repo_root/build/android/pauli-$abi.apk"

sha256sum "$repo_root/build/android/pauli-$abi.apk"
