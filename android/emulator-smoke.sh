#!/bin/sh
set -eu

apk=build/android/pauli-x86_64.apk
package=org.isomorphisms.pauli
component="$package/android.app.NativeActivity"
log=build/android/emulator.log

adb install -r "$apk"
adb logcat -c
adb shell am start -S -W -n "$component"

timeout 20 sh -c 'until adb logcat -d | grep -Fq "PauliNative: EGL surface ready:"; do sleep 1; done'
timeout 20 sh -c 'until adb logcat -d | grep -Fq "PauliNative: frame presented"; do sleep 1; done'

adb shell input swipe 250 600 700 600 500
adb shell input tap 500 800
sleep 2

adb logcat -d > "$log"
adb exec-out screencap -p > build/android/emulator.png

adb shell pidof -s "$package" |
  tr -d '\r' |
  grep -Eq '^[0-9]+$'

grep -Fq 'PauliNative: native entry' "$log"
grep -Fq 'PauliNative: EGL surface ready:' "$log"
grep -Fq 'PauliNative: frame presented' "$log"
grep -Fq 'PauliNative: drag:' "$log"
grep -Fq 'PauliNative: tap: cycle orbital' "$log"

! grep -Eiq 'FATAL EXCEPTION|UnsatisfiedLinkError|VerifyError|ClassNotFoundException' "$log"
