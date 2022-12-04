#!/bin/zsh

#  screenshots.sh
#  Money
#
#  Created by dani on 11/17/22.
#

# The Xcode project to create screenshots for
projectName="./Money.xcodeproj"

# The scheme to run tests for
schemeName="Money"

# All the simulators we want to screenshot
# Copy/Paste new names from Xcode's
# "Devices and Simulators" window
# or from `xcrun simctl list`.

simulators=(
    "iPhone 14 Pro Max"
    "iPhone 13 Pro Max"
    "iPhone 8 Plus"
    "iPad Pro (12.9-inch) (6th generation)"
)

# All the languages we want to screenshot (ISO 3166-1 codes)
languages=(
    "en"
)

# All the appearances we want to screenshot
# (options are "light" and "dark")
appearances=(
    "light"
    "dark"
)

# Save final screenshots into this folder (it will be created)
targetFolder="/Users/dani/Desktop/MoneyScreenshots"
rm -rf /Users/dani/Desktop/MoneyScreenshots

for simulator in "${simulators[@]}"; do
    for language in "${languages[@]}"; do
        for appearance in "${appearances[@]}"; do
            rm -rf /tmp/MoneyDerivedData/Logs/Test
            echo "📲 Building and Running for $simulator in $language"

            # Boot up the new simulator and set it to
            # the correct appearance
            xcrun simctl boot "$simulator"
            xcrun simctl ui booted appearance "$appearance"
            # Build and Test
            xcodebuild -testLanguage "$language" -scheme $schemeName -project $projectName -derivedDataPath '/tmp/MoneyDerivedData/' -destination "platform=iOS Simulator,name=$simulator" build test
            echo "Collecting Results..."
            mkdir -p "$targetFolder/$simulator/"
            find /tmp/MoneyDerivedData/Logs/Test -maxdepth 1 -type d -exec xcparse screenshots {} "$targetFolder/$simulator/" \;
        done
    done

    echo "✅ Done"
done
