#!/bin/bash

# Markdown QuickLook Installation Script
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$DIR/.."
cd "$PROJECT_ROOT"

CONFIGURATION=${1:-Release}

echo "🚀 Installing Markdown QuickLook ($CONFIGURATION configuration)..."
echo ""

# 1. Build the app
echo "📦 Building application..."
make app CONFIGURATION="$CONFIGURATION"

# 2. Copy to Applications
echo "🔍 Locating built application..."
APP_PATH=""

for path in ~/Library/Developer/Xcode/DerivedData/MarkdownPreviewEnhanced-*/Build/Products/"$CONFIGURATION"/"Markdown Preview Enhanced.app"; do
    if [ -d "$path" ]; then
        if [ -z "$APP_PATH" ] || [ "$path" -nt "$APP_PATH" ]; then
            APP_PATH="$path"
        fi
    fi
done

if [ -z "$APP_PATH" ]; then
    echo "❌ Error: Could not find built application in DerivedData."
    echo "   Expected path: .../Build/Products/$CONFIGURATION/Markdown Preview Enhanced.app"
    echo "   Please check if the build succeeded."
    exit 1
fi

echo "📋 Found app at: $APP_PATH"
echo "📋 Installing to /Applications..."
rm -rf "/Applications/Markdown Preview Enhanced.app"
cp -R "$APP_PATH" /Applications/

# 3. Register with LaunchServices
echo "🔧 Registering with system..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "/Applications/Markdown Preview Enhanced.app"

# 4. Reset QuickLook
echo "🔄 Resetting QuickLook cache..."
qlmanage -r
qlmanage -r cache

echo ""
echo "✅ Installation complete!"
echo ""
echo "⚠️  IMPORTANT: To activate the QuickLook preview, you need to:"
echo "   1. Right-click任意 .md 文件"
echo "   2. 选择 '显示简介' (Get Info) 或按 ⌘+I"
echo "   3. 在 '打开方式' (Open with:) 部分，选择 'Markdown Preview Enhanced.app'"
echo "   4. 点击 '全部更改...' (Change All...) 按钮"
echo "   5. 点击 '继续' 确认"
echo ""
echo "💡 This sets Markdown Preview Enhanced as the default app for all .md files,"
echo "   which is required for the QuickLook extension to work."
echo ""
echo "🧪 After setting the default app, test with: qlmanage -p test-sample.md"
