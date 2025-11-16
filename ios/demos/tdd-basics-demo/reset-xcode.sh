#!/bin/bash

# Script to reset Xcode project state for TDD Basics Demo
# Run this if tests aren't showing up in Xcode's Test Navigator

echo "🧹 Cleaning Swift Package Manager build artifacts..."
rm -rf .build

echo "🗑️  Removing Xcode derived data for this project..."
rm -rf ~/Library/Developer/Xcode/DerivedData/TDDBasicsDemo-*

echo "🔄 Resetting Swift package..."
swift package reset

echo "📦 Resolving package dependencies..."
swift package resolve

echo "✅ Done! Now:"
echo "   1. Close Xcode completely (Cmd+Q)"
echo "   2. Open Package.swift again: open Package.swift"
echo "   3. Wait for Xcode to finish indexing"
echo "   4. Press Cmd+6 to open Test Navigator"
echo "   5. Both CalculatorTests and SpeakingClockTests should appear"
echo ""
echo "If tests still don't show:"
echo "   - Product → Clean Build Folder (Cmd+Shift+K)"
echo "   - Product → Build (Cmd+B)"
echo "   - Try running a test by clicking the diamond icon in the editor"
