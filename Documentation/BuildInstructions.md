xcodebuild \
-workspace Atlas.xcodeproj/project.xcworkspace \
-scheme AtlasAppUITests \
-destination 'platform=OS X,arch=x86_64' \
test


GENERATE: swift package generate-xcodeproj --xcconfig-overrides settings.xcconfig
BUILD: swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"
RUN: swift run -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13" Atlas
BUILD FOR DISTRIBUTION: swift build -c release -Xswiftc -static-stdlib -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"
S3 LOCALSTACK: sudo SERVICES=s3 localstack start >> /dev/null 2>&1


Rebuilding
swift package update
swift package generate-xcodeproj --xcconfig-overrides settings.xcconfig
Add Target: AtlasApp
Set "Product Name" to "AtlasApp"
Set "Organization Identifier" to "powderhs"
In AtlasApp Target find "Swift Language Version" and set to "Swift 4"
In AtlasApp Target && AtlasAppUITests Target find "Import Paths" and add:
 ${SRCROOT}/Atlas.xcodeproj/GeneratedModuleMap/CLibreSSL
 ${SRCROOT}/Atlas.xcodeproj/GeneratedModuleMap/CHTTPParser
Move all files from AtlasApp (old) to AtlasApp (new)
Move all files from AtlasAppUITests (old) to AtlasAppUITests (new)
git status
git checkout AtlasApp
rm AtlasApp/ViewController.swift
rm AtlasAppUITests/AtlasAppUITests.swift
Delete old and "Remove Reference" for app and ui tests
Delete red files
Add AtlasCore and all non-testing libraries as Embedded Binary to AtlasApp
Assign all lib file (within AtlasApp) to AtlasApp
Assign main.storyboard in Base.lproj
In AtlasCore target add a "Copy Bundle Resources" item to "Build Phases" and select "git"
git checkout Atlas.xcodeproj/GeneratedModuleMap/CHTTPParser/module.modulemap
ensure all AtlasApp.xcodeproj/GeneratedModuleMap are pointing to the right .build/checkouts
For testing may need to create copies of .build/checkouts to match version numbers (how to fix this?)
