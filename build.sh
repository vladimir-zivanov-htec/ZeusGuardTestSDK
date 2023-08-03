#!/bin/bash

xcodebuild archive \
-workspace ZeusGuard.xcworkspace \
-scheme ZeusGuard \
-destination "generic/platform=iOS" \
-archivePath ../output-pods/ZeusGuard-iOS \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
-workspace ZeusGuard.xcworkspace \
-scheme ZeusGuard \
-destination "generic/platform=iOS Simulator" \
-archivePath ../output-pods/ZeusGuard-iOS-Sim \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
-framework ../output-pods/ZeusGuard-iOS.xcarchive/Products/Library/Frameworks/ZeusGuardTestSDK.framework \
-framework ../output-pods/ZeusGuard-iOS-Sim.xcarchive/Products/Library/Frameworks/ZeusGuardTestSDK.framework \
-output ../output-pods/ZeusGuardTestSDK.xcframework
