#  Created by Rohit Kumar on 28/04/20.
#  Copyright © 2020 Geidea Solutions. All rights reserved.
#

#!/bin/sh

rm -R XCFramework

# -----------------------------------------------
# BUILD PLATFORM SPECIFIC FRAMEWORKS
# -----------------------------------------------

# iOS devices
xcodebuild archive \
-scheme GeideaParsingLib \
-archivePath "./XCFramework/build/ios.xcarchive" \
-sdk iphoneos \
SKIP_INSTALL=NO

# iOS simulator
xcodebuild archive \
-scheme GeideaParsingLib \
-archivePath "./XCFramework/build/ios_sim.xcarchive" \
-sdk iphonesimulator \
SKIP_INSTALL=NO

# -----------------------------------------------
#  PACKAGE XCFRAMEWORK
# -----------------------------------------------

xcodebuild -create-xcframework \
-framework "./XCFramework/build/ios.xcarchive/Products/Library/Frameworks/GeideaParsingLib.framework" \
-framework "./XCFramework/build/ios_sim.xcarchive/Products/Library/Frameworks/GeideaParsingLib.framework" \
-output "./XCFramework/GeideaParsingLib.xcframework"

