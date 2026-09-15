#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "===================================================="
echo "📱 بناء تطبيق دوّنلي للأندرويد (Dawenly Android APK)"
echo "===================================================="

# ضبط بيئة Java 17
if [ -d "/home/d/jdk-17" ]; then
  export JAVA_HOME="/home/d/jdk-17"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

if ! command -v java &>/dev/null; then
  echo "❌ تعذر العثور على Java! يرجى التأكد من تثبيت OpenJDK 17."
  exit 1
fi

echo "☕ Java Version: $(java -version 2>&1 | head -n 1)"

# ضبط مسار Android SDK
if [ -d "/home/d/android-sdk" ]; then
  export ANDROID_HOME="/home/d/android-sdk"
  export ANDROID_SDK_ROOT="/home/d/android-sdk"
  export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
fi

cd "$ROOT_DIR"

# 1. مزامنة أصول الويب مع كاباسيتور
echo ""
echo "🔄 جاري مزامنة ملفات الواجهة مع مشروع الأندرويد..."
npx cap sync android

# 2. توليد الأيقونات وشاشات البداية إذا لزم الأمر
if [ -f "$ROOT_DIR/scripts/generate-android-assets.py" ]; then
  python3 "$ROOT_DIR/scripts/generate-android-assets.py"
fi

# 3. بناء الـ APK عبر Gradle
echo ""
echo "🔨 جاري تجميع ملف الـ APK عبر Gradle (assembleDebug)..."
cd "$ROOT_DIR/android"

chmod +x gradlew
./gradlew assembleDebug

APK_PATH="$ROOT_DIR/android/app/build/outputs/apk/debug/app-debug.apk"
TARGET_APK="$ROOT_DIR/dawenly-android.apk"

if [ -f "$APK_PATH" ]; then
  cp "$APK_PATH" "$TARGET_APK"
  echo ""
  echo "===================================================="
  echo "✅ تم بناء تطبيق الأندرويد الأصلي (Capacitor) بنجاح 100%!"
  echo "===================================================="
  echo "📦 مسار الملف المباشر: $TARGET_APK"
  echo "📊 الحجم: $(ls -lh "$TARGET_APK" | awk '{print $5}')"
  echo "🔐 SHA256: $(sha256sum "$TARGET_APK" | awk '{print $1}')"
  echo ""
  echo "📲 طرق التثبيت:"
  echo "1. عبر كابل USB وأمر ADB:"
  echo "   $ANDROID_HOME/platform-tools/adb install -r $TARGET_APK"
  echo "2. إرسال ملف dawenly-android.apk إلى هاتفك مباشرة (عبر Telegram أو WhatsApp أو Google Drive وتثبيته بلمسة واحدة)."
  echo "===================================================="
else
  echo "❌ تعذر العثور على ملف APK بعد انتهاء التجميع."
  exit 1
fi
