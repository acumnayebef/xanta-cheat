#!/bin/bash
set -euo pipefail

SDK=$(xcrun --sdk iphoneos --show-sdk-path)
MIN_IOS="15.0"
OUT="build"
DYLIB="libcheat.dylib"
DOBBY_DIR="third_party/dobby"

mkdir -p "$OUT"

echo "[*] SDK:    $SDK"
echo "[*] Output: $OUT/$DYLIB"

# --- Locate Dobby ---
DOBBY_LIB=""
for lib in $(find "$DOBBY_DIR" -name "*.a" 2>/dev/null); do
    if lipo -info "$lib" 2>/dev/null | grep -q "arm64"; then
        DOBBY_LIB="$lib"
        break
    fi
done

DOBBY_INC=$(find "$DOBBY_DIR" -name "dobby.h" -path "*/include/*" 2>/dev/null | head -1)

if [ -z "$DOBBY_LIB" ]; then
    echo "[!] libdobby.a (arm64) not found in $DOBBY_DIR"
    exit 1
fi

echo "[*] Dobby lib: $DOBBY_LIB"
[ -n "$DOBBY_INC" ] && echo "[*] Dobby inc: $DOBBY_INC"

INCLUDES=""
[ -n "$DOBBY_INC" ] && INCLUDES="-I$(dirname "$DOBBY_INC")"

# --- Compile ---
xcrun --sdk iphoneos clang++ \
    -arch arm64 \
    -isysroot "$SDK" \
    -miphoneos-version-min="$MIN_IOS" \
    -dynamiclib \
    -fobjc-arc \
    -O2 \
    -std=c++17 \
    -Wl,-undefined,dynamic_lookup \
    -I"src" \
    $INCLUDES \
    -o "$OUT/$DYLIB" \
    src/tweak.mm \
    src/il2cpp_loader.mm \
    src/hooks.mm \
    "$DOBBY_LIB" \
    -framework Foundation \
    -framework UIKit \
    -framework CoreFoundation \
    -framework QuartzCore \
    -framework Security \
    -install_name "@executable_path/Frameworks/$DYLIB"

echo "[+] Built: $OUT/$DYLIB"
file "$OUT/$DYLIB"