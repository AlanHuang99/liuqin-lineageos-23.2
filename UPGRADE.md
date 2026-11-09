# Updating an existing liuqin installation

This guide covers a same-variant full OTA to `20261109` using compatible LineageOS recovery. It keeps userdata and metadata intact. The exact completed device tests are recorded in [release notes](RELEASE_NOTES.md#device-results).

| Current installation | Download |
| --- | --- |
| LineageOS 23.2 with Google apps built into the system | `lineage-23.2-20261109-UNOFFICIAL-liuqin-gapps.zip` |
| LineageOS 23.2 vanilla, without Google apps | `lineage-23.2-20261109-UNOFFICIAL-liuqin-vanilla.zip` |

The July date label and build fingerprint do not distinguish these variants. Check the installed package set and original build choice. Separately installed Google apps, microG, another ROM and switching between GApps and vanilla are outside this procedure. Recovery does not enforce the variant choice.

## Prepare

1. Confirm the tablet is Xiaomi Pad 6 Pro, codename `liuqin`. Make a current off-device backup and check that the saved files and app exports can be read.
2. Download the matching [OTA ZIP and SHA256SUMS](https://github.com/AlanHuang99/liuqin-lineageos-23.2/releases/tag/20261109). Check the ZIP against the [published checksum](README.md#downloads).
3. Read the [validation results](RELEASE_NOTES.md#host-validation). Rooted installations also need the separate boot-image handling described below.

## Recovery sideload

Set the actual ADB serial and verified ZIP path. This example selects GApps; use the vanilla filename for a vanilla installation.

```bash
LIUQIN_SERIAL='your-liuqin-adb-serial'
LIUQIN_ROM='lineage-23.2-20261109-UNOFFICIAL-liuqin-gapps.zip'
adb -s "$LIUQIN_SERIAL" shell getprop ro.product.device
sha256sum "$LIUQIN_ROM"
```

Confirm the device command returns `liuqin` and the hash matches the selected release ZIP, then reboot to recovery:

```bash
adb -s "$LIUQIN_SERIAL" reboot recovery
```

In recovery, choose **Apply update → Apply from ADB** and send the ZIP:

```bash
adb -s "$LIUQIN_SERIAL" sideload "$LIUQIN_ROM"
```

Require recovery's successful installation result. For an unrooted installation, return to the recovery menu and reboot to system. A rooted installation uses its separately prepared target boot image before the first new-system boot, as described below. If installation fails, retain the recovery error and diagnose it before retrying.

Do not select Factory reset or Format data, erase userdata/metadata, run `fastboot -w`, or use a stock `flash_all` script. Do not sideload a separate Google-app package. The full OTA carries the system and boot images needed for this update; separately flashing the release image assets is not an additional ordinary update step.

After boot, unlock with the original credential and check existing apps, accounts, files, Wi-Fi, camera/recording, keyboard and suspend/wake. Let the normal update/snapshot merge complete before a further update or slot change. Retain the backup until these checks pass.

## Rooted installations

The full OTA replaces the boot image. Retaining Magisk is evaluated separately from the ordinary OTA path using Magisk 30.7 and a newly patched copy of the exact target variant's `boot.img`. The [device-results record](RELEASE_NOTES.md#device-results) identifies the tested outcome.

Prepare the patch with your own matching Magisk tools and boot configuration. Verify the candidate binding, unchanged kernel/header fields, expected Magisk ramdisk and partition-size limit. After the OTA, establish the actual target slot and verify its stock boot against the candidate before applying the validated patched image; verify the write before booting. Do not reuse a July patched boot or another device's patched image. This project distributes unmodified boot images, not a pre-rooted image or a maintainer-specific root configuration. Module compatibility remains installation-specific.

Fresh installation and migration from another ROM require their own procedure. The July format-data instructions are not update steps.
