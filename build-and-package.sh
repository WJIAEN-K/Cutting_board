#!/bin/bash
# 构建并打包 ding（剪贴板）应用
# 因 Xcode 签名对扩展属性敏感，构建后需先清除 xattr 再签名、打包

set -e
cd "$(dirname "$0")"
BUILD_DIR=build
APP="$BUILD_DIR/Build/Products/Release/ding.app"
ZIP=ding-mac.zip

echo "→ 正在构建 Release..."
xcodebuild -scheme Cutting_board -configuration Release -derivedDataPath "$BUILD_DIR" build || true

if [[ ! -d "$APP" ]]; then
  echo "错误：未找到 $APP，请检查构建是否完成。"
  exit 1
fi

echo "→ 清除扩展属性并签名..."
xattr -cr "$APP"
codesign -s - --force --timestamp=none "$APP"

echo "→ 打包为 $ZIP ..."
rm -f "$ZIP"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"

echo "完成：$(ls -lh "$ZIP" | awk '{print $5}') → $ZIP"
