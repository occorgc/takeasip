#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

SWIFT_FILE="WaterReminder.swift" # Assumed filename from your RTF
APP_NAME="WaterReminder"
BUNDLE_ID="com.example.WaterReminder" # From your RTF
MACOS_TARGET="12.0" # From your RTF
ARCH_TARGET="arm64" # From your RTF

echo "--- Starting Build (Strictly based on RTF commands) ---"

# 1. Compile Swift Code (EXACTLY as in RTF - LACKS FRAMEWORKS)
echo "Compiling ${SWIFT_FILE} (NOTE: Missing framework links)..."
swiftc -target "${ARCH_TARGET}-apple-macosx${MACOS_TARGET}" -o "${APP_NAME}" "${SWIFT_FILE}"
# WARNING: This command is unlikely to produce a working GUI app executable
#          because -framework Cocoa and -framework SwiftUI are missing.

# Check if the file was created, even if potentially non-functional
if [ ! -f "${APP_NAME}" ]; then
    echo "Compilation failed or did not produce the output file."
    exit 1
fi
echo "Compilation command finished."

# 2. Create Bundle Structure (as in RTF)
echo "Creating bundle structure..."
mkdir -p "${APP_NAME}.app/Contents/MacOS"
mkdir -p "${APP_NAME}.app/Contents/Resources"

# 3. Copy Executable (as in RTF)
echo "Copying executable..."
cp "${APP_NAME}" "${APP_NAME}.app/Contents/MacOS/"

# 4. Create Info.plist (EXACTLY as in RTF)
echo "Creating Info.plist (with LSUIElement)..."
cat > "${APP_NAME}.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>${MACOS_TARGET}</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF
echo "Info.plist created."

# 5. Set Permissions (as in RTF)
echo "Setting executable permissions..."
chmod +x "${APP_NAME}.app/Contents/MacOS/${APP_NAME}"

# Note: Codesigning and cleanup steps are NOT included as they weren't in the RTF.

echo "--- Build Script Finished (Based strictly on RTF) ---"
echo "WARNING: The resulting ${APP_NAME}.app was built without linking essential frameworks."
echo "         It is unlikely to run correctly as a GUI application."