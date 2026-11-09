#!/bin/bash
# Apply the release patches to the clean, pinned device projects.
set -euo pipefail
if [[ $# != 1 ]]; then
  printf 'Usage: %s ANDROID_SOURCE_ROOT\n' "$0" >&2
  exit 2
fi
SOURCE_DIR=$(realpath "$1")
RELEASE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
COMMON_DIR="$SOURCE_DIR/device/xiaomi/sm8450-common"
DEVICE_DIR="$SOURCE_DIR/device/xiaomi/liuqin"
COMMON_PATCH="$RELEASE_DIR/patches/20261109/0001-sm8450-common-no-nfc.patch"
DEVICE_PATCH="$RELEASE_DIR/patches/20261109/0002-liuqin-maintenance.patch"

check_project() {
  local project=$1 revision=$2
  if [[ $(git -C "$project" rev-parse HEAD) != "$revision" ]]; then
    printf 'Unexpected source revision: %s\n' "$project" >&2
    exit 1
  fi
  if [[ -n $(git -C "$project" status --porcelain --untracked-files=all) ]]; then
    printf 'Preserve existing changes before applying release patches: %s\n' "$project" >&2
    exit 1
  fi
}

check_project "$COMMON_DIR" d5ab14b2f9c8c1b936bbd71fc71e35678bf7f7c5
check_project "$DEVICE_DIR" fcc1c87e37a6cee23d95229be3ab57bb6f2e9f6d
git -C "$COMMON_DIR" apply --check "$COMMON_PATCH"
git -C "$DEVICE_DIR" apply --check "$DEVICE_PATCH"
git -C "$COMMON_DIR" apply "$COMMON_PATCH"
git -C "$DEVICE_DIR" apply "$DEVICE_PATCH"
git -C "$COMMON_DIR" diff --check
git -C "$DEVICE_DIR" diff --check
printf 'Applied liuqin maintenance patches.\n'
