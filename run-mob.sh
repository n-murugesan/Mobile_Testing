#!/bin/bash

EMULATOR_PATH=$ANDROID_HOME/emulator/emulator
ADB_PATH=$ANDROID_HOME/platform-tools/adb

echo "🚀 Getting AVD list..."
avdList=$($EMULATOR_PATH -list-avds)

echo "AVD list: $avdList"

avdName=$(echo "$avdList" | head -n 1)

echo "Selected AVD: $avdName"

$EMULATOR_PATH -avd "$avdName" -no-snapshot-save &
sleep 10

echo "⌛ Waiting for emulator to boot..."
while true; do
  deviceState=$($ADB_PATH get-state 2>/dev/null)
  bootComplete=$($ADB_PATH shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
  echo "deviceState: $deviceState"
  echo "bootComplete: $bootComplete"
  if [[ "$deviceState" == "device" && "$bootComplete" == "1" ]]; then
    break
  fi
  sleep 2
done

echo "✅ Emulator is fully booted and ready"
echo "🧪 Running tests with WebdriverIO..."
npx wdio run wdio.conf.ts
