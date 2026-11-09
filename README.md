# LineageOS 23.2 for Xiaomi Pad 6 Pro (liuqin)

Unofficial LineageOS 23.2, based on Android 16, for Xiaomi Pad 6 Pro (`liuqin`, model 23046RP50C). This project is independent of LineageOS and Xiaomi.

**20261109 maintenance prerelease.** The GApps build completed a same-variant July update with data-retention checks and a second reboot. Both variants have completed host artifact checks. Physical pen use and vanilla device installation/upgrade remain untested. See the [release notes](RELEASE_NOTES.md#device-results) for the recorded device results.

## Downloads

| Variant | Contents | OTA ZIP | Size |
| --- | --- | --- | --- |
| GApps | Google apps built into the ROM | [lineage-23.2-20261109-UNOFFICIAL-liuqin-gapps.zip](https://github.com/AlanHuang99/liuqin-lineageos-23.2/releases/download/20261109/lineage-23.2-20261109-UNOFFICIAL-liuqin-gapps.zip) | 2,083,368,210 bytes |
| Vanilla | No bundled Google apps | [lineage-23.2-20261109-UNOFFICIAL-liuqin-vanilla.zip](https://github.com/AlanHuang99/liuqin-lineageos-23.2/releases/download/20261109/lineage-23.2-20261109-UNOFFICIAL-liuqin-vanilla.zip) | 1,779,185,641 bytes |

| OTA variant | SHA-256 |
| --- | --- |
| GApps | `78567e0491c8b260770cc4c2d64d1419fd064065b2b0da786e08236206b6ec26` |
| Vanilla | `77d09951f865b3f0de152096c64d730c3f8531675f918a7ecd295599aa56aad9` |

A [SourceForge mirror](https://sourceforge.net/projects/liuqin-lineageos/files/23.2-20261109/) carries the same files.

The [release assets](https://github.com/AlanHuang99/liuqin-lineageos-23.2/releases/tag/20261109) also contain matching `boot`, `recovery`, `vendor_boot`, `dtbo`, `vbmeta` and `vbmeta_system` images named by variant. Check downloads against [SHA256SUMS](https://github.com/AlanHuang99/liuqin-lineageos-23.2/releases/download/20261109/SHA256SUMS). The separate images are not extra flashing steps for an ordinary OTA update.

Keep the current variant when updating: GApps to GApps or vanilla to vanilla. The shared build fingerprint does not identify the variant, and the OTA does not reject a cross-variant choice. Existing installations with separately installed Google apps or microG need their own migration assessment.

The images use EROFS. Google-app installers that require writable system mounts are unsupported; choose the built-in-GApps variant when Google services are required. The earlier July MindTheGapps sideload instruction is withdrawn.

## Changes

- Select the retained Xiaomi analog microphone routes, preserve the four-channel camera backend and remove the phantom FM input.
- Initialize the Smart Pen 2 connection state once per boot using the shipped touch driver's verified request layout and a dedicated SELinux domain.
- Stop Xiaomi Keyboard `15d9:00a3` arrow directions from rotating with the display.
- Make vanilla/GApps selection explicit and retain the NFC/SecureElement guards.
- Refresh the LineageOS 23.2 platform to SPL `2026-10-01`. Vendor SPL remains `2026-04-01`; the prebuilt kernel remains 5.10.252.

## Updates and source

Use the [same-variant upgrade guide](UPGRADE.md) without formatting data. Fresh installation and migration from another ROM are outside that guide. The [July release support note](LEGACY_20260709.md) retains the earlier artifact identity and corrects its Google-app instructions.

[Release notes](RELEASE_NOTES.md) contain the build identities, signature results, retained Exchange APK exception and open reports. The [build guide](BUILD.md), [pinned 1,174-project manifest](manifests/release-20261109.xml) and [maintenance patches](patches/20261109) describe the release inputs.

Report the build, variant, device model, steps and relevant logs through [GitHub issues](https://github.com/AlanHuang99/liuqin-lineageos-23.2/issues) or the [XDA thread](https://xdaforums.com/t/rom-16-unofficial-lineageos-23-2-for-xiaomi-pad-6-pro-liuqin.4794327/). Include the pen model for stylus reports and keyboard identifier/display rotation for keyboard reports.

Thanks to [LineageOS](https://github.com/LineageOS), [Sickyman678](https://github.com/Sickyman678), [Xiaomi-SM8475](https://github.com/Xiaomi-SM8475) and the community reporters. Repository build configuration, manifests and patches retain their existing Apache License 2.0 terms; component and proprietary-file licenses remain applicable.
