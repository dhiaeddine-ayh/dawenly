#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
FLUTTER_APP_DIR="$ROOT_DIR/flutter_app"

echo "===================================================="
echo "📱 بناء تطبيق دوّنلي الأصلي عبر فلاتر (Dawenly Flutter APK)"
echo "===================================================="

# ضبط بيئة Java 17
if [ -d "/home/d/jdk-17" ]; then
  export JAVA_HOME="/home/d/jdk-17"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

# ضبط بيئة Android SDK
if [ -d "/home/d/android-sdk" ]; then
  export ANDROID_HOME="/home/d/android-sdk"
  export ANDROID_SDK_ROOT="/home/d/android-sdk"
  export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
fi

# ضبط مسار Flutter
if [ -d "/home/d/flutter/flutter/bin" ]; then
  export PATH="/home/d/flutter/flutter/bin:$PATH"
elif [ -d "/home/d/flutter/bin" ]; then
  export PATH="/home/d/flutter/bin:$PATH"
fi

if ! command -v flutter &>/dev/null; then
  echo "❌ تعذر العثور على أداة flutter في PATH!"
  exit 1
fi

# التحقق من أدوات NDK LLVM اللازمة للرمز والتقليص
NDK_BIN="$ANDROID_HOME/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin"
if [ ! -f "$NDK_BIN/llvm-objcopy" ] && [ -d "/usr/lib/llvm-16/bin" ]; then
  mkdir -p "$NDK_BIN"
  for tool in llvm-objcopy llvm-strip llvm-nm llvm-readelf llvm-ar llvm-as llvm-strings llvm-objdump; do
    if [ -f "/usr/lib/llvm-16/bin/$tool" ]; then
      ln -sf "/usr/lib/llvm-16/bin/$tool" "$NDK_BIN/$tool"
    fi
  done
fi

BUILD_MODE="release"
if [ "$1" == "--debug" ]; then
  BUILD_MODE="debug"
fi

echo "🎯 Flutter Version: $(flutter --version | head -n 1)"
echo "☕ Java Version: $(java -version 2>&1 | head -n 1)"
echo "⚙️ نمط البناء: $BUILD_MODE"

cd "$FLUTTER_APP_DIR"

echo ""
echo "🔍 فحص كود Dart عبر flutter analyze..."
flutter analyze

echo ""
echo "🔨 جاري تجميع ملف APK ($BUILD_MODE)..."
if [ "$BUILD_MODE" == "release" ]; then
  flutter build apk --release
  ORIGINAL_APK="$FLUTTER_APP_DIR/build/app/outputs/flutter-apk/app-release.apk"
else
  flutter build apk --debug
  ORIGINAL_APK="$FLUTTER_APP_DIR/build/app/outputs/flutter-apk/app-debug.apk"
fi

TARGET_APK="$ROOT_DIR/dawenly-flutter.apk"

if [ -f "$ORIGINAL_APK" ]; then
  cp "$ORIGINAL_APK" "$TARGET_APK"
  echo ""
  echo "===================================================="
  echo "✅ تم بناء وتوليد تطبيق دوّنلي فلاتر بنجاح 100%!"
  echo "===================================================="
  echo "📦 مسار APK المباشر: $TARGET_APK"
  echo "📊 الحجم: $(ls -lh "$TARGET_APK" | awk '{print $5}')"
  echo "🔐 SHA256: $(sha256sum "$TARGET_APK" | awk '{print $1}')"
  echo ""
  echo "📲 طرق التثبيت على الهاتف:"
  echo "1. عبر كابل USB وأداة ADB:"
  echo "   $ANDROID_HOME/platform-tools/adb install -r $TARGET_APK"
  echo "2. إرسال ملف dawenly-flutter.apk إلى هاتفك مباشرة عبر (Telegram / WhatsApp / Drive) وتثبيته بلمسة واحدة."
  echo "===================================================="
else
  echo "❌ تعذر العثور على ملف APK في مسار البناء ($ORIGINAL_APK)."
  exit 1
fi
