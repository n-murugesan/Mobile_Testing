#!/usr/bin/env bash
set -Eeuo pipefail

AVD_NAME="${AVD_NAME:-api35-x86_64-play}"
SNAPSHOT_NAME="${SNAPSHOT_NAME:-default_boot}"
: "${SNAP_URL:=https://emulatorsnapshots.s3.ap-south-1.amazonaws.com/default_boot.zip?response-content-disposition=inline&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEEYaCmFwLXNvdXRoLTEiRzBFAiEAspwwXSZDG4CamTUnrzm9uq8CR%2FQ3KTd3sGoH%2BbNZflkCIGggtYBinKT0L1DkbDvr3r6xJUr3UOYV2qZAR%2BORWxkpKsIDCJ%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQAxoMNDU4MzkxNzY3MTIxIgwAv1B5YmXF5P2odEgqlgPEU1QERBJdyQ7e3qDtpMdXECU%2FoofNlNKB3%2BZF7He0aFG4AepfMdGWEoYDOpEh5Urqk11u5QCpJKK6H%2BVSDJqmvXE%2FRKo78Ee1LXl8JaeVf1%2FnWawFZfr11QHNQQlMWFCE%2B0EWtYpcznqa06U0umQtrWwAZA%2FHPbblY1C61Rg%2FIGdUMI54oIfEvdwSJ5YAqplz3HWMaQhGxQAo01b3mqsrfiX7CqiHocamDkFreDovKj3PeM9WzLNfrHz9zFDUtT33zt%2BK5U%2FTNeaElHbLsYssxx4umBs35EgxRaUnMgg%2FQdYWFTfC81wViulcnuCt62pNAuxfO9Rx8e8EJhdiFbPavvocElJDi9B6jWPKPy7NGLNkHzvUTdgGtjW7tM4g0rjWQjIrSGQha0JFh3eMJhXgtqEwqToxsijRxO6mSSriXK6%2BAs7eBtS1ENb3%2FiD2hZQdYoY13FJdUBJ8IhrSpM0DZrcaSwZqcuKg%2B2TS2fftp45ednvkwJDEgxXS%2B7puBQCIy14DhfDd3rpS8ilT%2BWlq4yvmLPpvMIHZv8UGOt4CSF6dYw7iXDosA57Kr38oQlr9cZzvhKQe9VP76Zg6b%2BzdwalDE6ddrAVRrcatKDVR%2FnX%2BtwtM3VJl3CSkhB97AgQ9oMi07k0OkDkqi4nKUEEV4XZHfEYdjESbdbLv9xxtMEMsLjlf%2F2omuDMmZY8F4Vx8M6qSRuqJzwSNirTFtB9NQLpWAR%2Fxs%2F3YKvNzO4dKQS9sdD%2F0x%2BtwIoEFrdFo%2B1O5KeljkNgOBCq8ry5%2Bx06VCrg7wwzfokgop8wc3GBXlLJ4i2x82BY1xy4osdTTLjwn1tU9mWfn2HpezQriioKBx4sZvcvBAgjYR6CyHaqzKEmVtYI9xJjktlaGnG4BWtjlllbnHUN%2FOedW7F9ck3FrAQHWPco4ttYjovibwcNMqyurm01DJVeCU%2B7LO6rTLjRv4u8o4Pk7%2FLTdDrIWhan2KIbh7D7LnhjIWuuiRTH%2F7z6vozNdYQ1IjU5zO1Y%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAWVOSHJBIRXXWJYKS%2F20250828%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Date=20250828T054430Z&X-Amz-Expires=36000&X-Amz-SignedHeaders=host&X-Amz-Signature=d2523628a9ae40e8d65c0d23c79542bdaa12130a15e25401a3926e76225cfd59}"
echo "[DEBUG] SNAP_URL length: ${#SNAP_URL}"
printf '[DEBUG] SNAP_URL head: %.120s\n' "$SNAP_URL"

SDK_ROOT="${ANDROID_SDK_ROOT:-/opt/android-sdk}"
ADB="${SDK_ROOT}/platform-tools/adb"
EMULATOR_BIN="${SDK_ROOT}/emulator/emulator"

EMULATOR_OPTS="${EMULATOR_OPTS:-"-no-window -gpu swiftshader_indirect -noaudio -no-boot-anim -no-metrics"}"

HOME_AVD_BASE="${HOME}/.android"
AVD_DIR="${HOME_AVD_BASE}/avd/${AVD_NAME}.avd"
LOG_FILE="/tmp/emulator.log"
EMU_PID=

log() { echo -e "[$(date +'%H:%M:%S')] $*"; }
dump_logs() { echo; echo "------ emulator.log (tail) ------"; [[ -f "$LOG_FILE" ]] && tail -n 200 "$LOG_FILE" || echo "(no log yet)"; }
die() { echo -e "\nFATAL: $*"; dump_logs; exit 1; }
require_bin() { command -v "$1" >/dev/null 2>&1 || die "Missing required binary: $1"; }
trap '[[ -n "${EMU_PID:-}" ]] && (kill -0 "$EMU_PID" 2>/dev/null || true); dump_logs' EXIT

require_bin curl
require_bin unzip
require_bin "${ADB}"
[[ -x "${EMULATOR_BIN}" ]] || die "Emulator binary not found at ${EMULATOR_BIN}"

log "[INFO] AVD_NAME=${AVD_NAME}"
log "[INFO] SNAPSHOT_NAME=${SNAPSHOT_NAME}"
log "[INFO] SDK_ROOT=${SDK_ROOT}"

prepare_ext4_home() {

  if mount | grep -q "/mnt/avd-ext4 "; then
    log "[FS] ext4 already mounted."
    return
  fi
  log "[FS] Creating ext4 loop image for ~/.android (required for file-backed quickboot)..."

  mkdir -p /mnt/avd-ext4
  IMG="/mnt/avd-ext4/avd.img"
  [[ -f "$IMG" ]] || dd if=/dev/zero of="$IMG" bs=1M count=0 seek=8192 status=none
  mkfs.ext4 -F "$IMG" >/dev/null 2>&1
  mount -o loop "$IMG" /mnt/avd-ext4
  mkdir -p /mnt/avd-ext4/android-home
  if [[ -d "${HOME_AVD_BASE}" && ! -L "${HOME_AVD_BASE}" ]]; then
    shopt -s dotglob nullglob
    if compgen -G "${HOME_AVD_BASE}/*" > /dev/null; then
      log "[FS] Migrating existing ~/.android into ext4 volume..."
      mv "${HOME_AVD_BASE}"/* /mnt/avd-ext4/android-home/ || true
    fi
    rmdir "${HOME_AVD_BASE}" 2>/dev/null || true
  fi
  ln -sfn /mnt/avd-ext4/android-home "${HOME_AVD_BASE}"
  mkdir -p "${HOME_AVD_BASE}/avd"
  chmod 700 /mnt/avd-ext4/android-home || true
}

ensure_sdk() {
  log "[SDK] Accepting licenses / ensuring packages..."
  yes | "${SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null || true
  "${SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager" --install \
    "platform-tools" "platforms;android-35" "emulator" \
    "system-images;android-35;google_apis_playstore;x86_64" >/dev/null
}

ensure_avd() {
  if [[ -d "${AVD_DIR}" ]]; then
    log "[AVD] Found ${AVD_NAME}"
    return
  fi
  log "[AVD] Creating ${AVD_NAME} (non-interactive)..."
  "${SDK_ROOT}/cmdline-tools/latest/bin/avdmanager" create avd \
    --force \
    --name "${AVD_NAME}" \
    --package "system-images;android-35;google_apis_playstore;x86_64" \
    --abi "google_apis_playstore/x86_64" \
    --device "pixel_5" >/dev/null

  [[ -d "${AVD_DIR}" ]] || die "AVD dir not created: ${AVD_DIR}"
  awk '
    BEGIN{ram=0;cpu=0}
    /^hw.ramSize *=/ {print "hw.ramSize = 2048M"; ram=1; next}
    /^hw.cpu.ncore *=/ {print "hw.cpu.ncore = 4"; cpu=1; next}
    {print}
    END{
      if(!ram) print "hw.ramSize = 2048M";
      if(!cpu) print "hw.cpu.ncore = 4";
    }
  ' "${AVD_DIR}/config.ini" > "${AVD_DIR}/config.ini.tmp" && mv "${AVD_DIR}/config.ini.tmp" "${AVD_DIR}/config.ini"
}
inject_snapshot() {
  local tmpdir src cfg
  tmpdir="$(mktemp -d)"

  log "[SNAPSHOT] Downloading snapshot..."
  curl -L --fail --retry 5 --retry-all-errors --retry-delay 1 \
    -o "${tmpdir}/snap.zip" "${SNAP_URL}"

  log "[SNAPSHOT] Unzipping..."
  mkdir -p "${tmpdir}/unzipped"
  unzip -o "${tmpdir}/snap.zip" -d "${tmpdir}/unzipped" >/dev/null

  if [[ -d "${tmpdir}/unzipped/snapshots/${SNAPSHOT_NAME}" ]]; then
    src="${tmpdir}/unzipped/snapshots/${SNAPSHOT_NAME}"
  elif [[ -d "${tmpdir}/unzipped/${SNAPSHOT_NAME}" ]]; then
    src="${tmpdir}/unzipped/${SNAPSHOT_NAME}"
  else
    src="${tmpdir}/unzipped"
  fi

  mkdir -p "${AVD_DIR}/snapshots/${SNAPSHOT_NAME}"
  cp -a "${src}/." "${AVD_DIR}/snapshots/${SNAPSHOT_NAME}/"

  [[ -f "${AVD_DIR}/snapshots/${SNAPSHOT_NAME}/ram.img" ]] || die "Snapshot missing ram.img"
  [[ -f "${AVD_DIR}/snapshots/${SNAPSHOT_NAME}/snapshot.pb" ]] || die "Snapshot missing snapshot.pb"

  cfg="${AVD_DIR}/config.ini"
  touch "${cfg}"
  sed -i.bak '/^fastboot\.forceChosenSnapshotBoot/d' "${cfg}" || true
  sed -i.bak '/^fastboot\.chosenSnapshotFile/d' "${cfg}" || true
  sed -i.bak '/^disk\.dataPartition\.size/d' "$cfg" || true
  echo "disk.dataPartition.size=2048M" >> "$cfg"

  {
    echo "fastboot.forceChosenSnapshotBoot = yes"
    echo "fastboot.chosenSnapshotFile = snapshots/${SNAPSHOT_NAME}"
  } >> "${cfg}"

  log "[SNAPSHOT] Ready. Listing:"
  ls -lah "${AVD_DIR}/snapshots/${SNAPSHOT_NAME}" || true
}

launch_emulator() {
  log "[ADB] Restarting server..."
  "${ADB}" kill-server >/dev/null 2>&1 || true
  "${ADB}" start-server >/dev/null 2>&1 || true

  rm -f "${LOG_FILE}"
  log "[EMU] Starting with snapshot '${SNAPSHOT_NAME}' (read-only, no-save) ..."
  "${EMULATOR_BIN}" -avd "${AVD_NAME}" \
    -snapshot "${SNAPSHOT_NAME}" \
    -read-only -no-snapshot-save \
    -partition-size 2048 \
    -port 5554 \
    ${EMULATOR_OPTS} >> "${LOG_FILE}" 2>&1 &

  EMU_PID=$!
  sleep 2
  kill -0 "${EMU_PID}" 2>/dev/null || die "Emulator process exited immediately after launch"
}

wait_for_boot() {
  log "[CHECK] Verifying snapshot actually loaded..."
  sleep 8
  if grep -q "Failed to load snapshot '${SNAPSHOT_NAME}'" "${LOG_FILE}" 2>/dev/null; then
    die "Emulator failed to load the requested snapshot '${SNAPSHOT_NAME}'. (ext4 is required)"
  fi

  log "[WAIT] adb wait-for-device (60s)..."
  timeout 60s "${ADB}" wait-for-device || die "adb never saw a device"

  log "[WAIT] sys.boot_completed (120s)..."
  timeout 120s bash -lc "until ${ADB} shell getprop sys.boot_completed 2>/dev/null | grep -q 1; do sleep 1; done" \
    || die "Device did not report sys.boot_completed"

  "${ADB}" shell getprop ro.product.cpu.abi >/dev/null || die "Device unresponsive after boot"
  log "[OK] Emulator is up from snapshot."
}

prepare_ext4_home
ensure_sdk
ensure_avd
inject_snapshot
launch_emulator
wait_for_boot

if [[ -f "/work/wdio.conf.ts" || -f "/work/wdio.conf.js" ]]; then
  log "[RUN] Detected WDIO config; launching Appium + tests..."
  appium --relaxed-security >/tmp/appium.log 2>&1 &
  APPIUM_PID=$!
  sleep 5
  if command -v npx >/dev/null 2>&1; then
    npx wdio run /work/wdio.conf.ts || npx wdio run /work/wdio.conf.js
  else
    log "[WARN] npx not found; skipping tests."
  fi
  kill "${APPIUM_PID}" >/dev/null 2>&1 || true
else
  log "[INFO] No WDIO config found; keeping emulator running."
  tail -f "${LOG_FILE}"
fi
