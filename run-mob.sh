#!/bin/bash

# Load environment variables from .env file
source .env

# Load configuration settings based on environment
if [ "$ENVIRONMENT" = "local" ]; then
  # Load local configuration settings
  echo "Running tests locally"
  # Set local-specific variables
  avdName="Pixel_9_Pro"
  androidHome="$ANDROID_HOME"

elif [ "$ENVIRONMENT" = "cloud" ]; then
  # Load cloud configuration settings
  echo "Running tests in cloud"
  # Set cloud-specific variables
  aavdName="Pixel_9_Pro"
  androidHome="$ANDROID_HOME"
else
  echo "Invalid environment"
  exit 1
fi

# Starting Android Emulator
echo "Starting Android Emulator: $avdName"
"$androidHome/emulator/emulator" -avd "$avdName" -no-snapshot-save &

# Waiting for emulator to boot...
echo "Waiting for emulator to boot..."

# Loop until emulator is ready
while true; do
#   deviceState=$(adb get-state 2>/dev/null)
#   bootComplete=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
#   bootAnim=$(adb shell getprop init.svc.bootanim 2>/dev/null | tr -d '\r')
#   settingsCheck=$(adb shell service call settings 2>&1)

#   echo "deviceState: $deviceState"
#   echo "bootComplete: $bootComplete"
#   echo "bootAnim: $bootAnim"
#   echo "settingsCheck: $settingsCheck"

    deviceState=$("$androidHome/platform-tools/adb" get-state 2>/dev/null)
    bootComplete=$("$androidHome/platform-tools/adb" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
    bootAnim=$("$androidHome/platform-tools/adb" shell getprop init.svc.bootanim 2>/dev/null | tr -d '\r')
    settingsCheck=$("$androidHome/platform-tools/adb" shell service call settings 2>&1)

    echo "deviceState: $deviceState"
    echo "bootComplete: $bootComplete"
    echo "bootAnim: $bootAnim"
    echo "settingsCheck: $settingsCheck"


  if [[ "$deviceState" == "device" && "$bootComplete" == "1" && "$bootAnim" == "stopped" && "$settingsCheck" != "Can't find service" ]]; then
    break
  fi

  sleep 2
done

echo "Emulator is fully booted and ready"
echo "Running tests with WebdriverIO..."
npx wdio run wdio.conf.ts