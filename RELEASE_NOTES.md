# LineageOS 23.2 maintenance prerelease, 20261109

For Xiaomi Pad 6 Pro (`liuqin`). [Downloads and OTA checksums](README.md#downloads). This prerelease includes separate GApps and vanilla builds; physical pen and vanilla device installation/upgrade tests are not complete.

## Build identity

| Item | Value |
| --- | --- |
| Version | `23.2-20261109-UNOFFICIAL-liuqin` |
| Android | 16, SDK 36, SDK full 36.1 |
| Platform security patch | `2026-10-01` |
| Vendor security patch | `2026-04-01` |
| Kernel | Retained prebuilt 5.10.252 |
| GApps build timestamp | `1794191423`, November 9, 2026 at 02:30:23 UTC |
| Vanilla build timestamp | `1794201696`, November 9, 2026 at 05:21:36 UTC |
| Build type / signing | `userdebug`; retained July test-key signing configuration |

Both variants use fingerprint `Xiaomi/lineage_liuqin/liuqin:16/BP4A.251205.006/eng.alan:userdebug/test-keys`. Select the variant by its named artifact and contents, not by the fingerprint. The patch levels above come from the built images; the November build date does not imply a November security patch level.

## Changes and source

- Use the Xiaomi analog ADC microphone routes, retain the four-channel camera backend and remove the phantom FM input.
- Supply the Smart Pen 2 driver's connection event once per boot with a full-size request buffer, dedicated SELinux domain and repeat-start guard.
- Disable orientation-dependent arrow mapping for Xiaomi Keyboard `15d9:00a3`.
- Require an explicit `gapps` or `vanilla` build selection and retain the device's NFC/SecureElement guards.
- Refresh the official LineageOS 23.2 platform while retaining device/vendor sources, the prebuilt kernel, kernel source dependencies and pinned Google apps.

The [release manifest](manifests/release-20261109.xml) pins 1,174 projects and is applied with the [two maintenance patches](patches/20261109). Its SHA-256 is `9a8b7ac3b7f6e94249e27f6a7d8eb15a1c2ec928271d89ca2690e77d41376569`. The platform refresh uses official manifest `3f9562ae369330b3881d5f625cf3f5d97aad9537` and `vendor/lineage` revision `259ba6626a9e3888e6b60732fb3f829e7de8f26e`. The [pinned platform release flag](https://github.com/LineageOS/android_vendor_lineage/blob/259ba6626a9e3888e6b60732fb3f829e7de8f26e/release/flag_values/bp4a/RELEASE_PLATFORM_SECURITY_PATCH.textproto) agrees with the built October SPL.

## Host validation

| Check | GApps | Vanilla |
| --- | --- | --- |
| Complete build and flavor contents | Pass; 16 pinned Google APKs and four GApps overlays present | Pass; those APKs and overlays absent |
| Whole OTA and payload signatures | Verified with retained OTA certificate and source tools | Verified with retained OTA certificate and source tools |
| APK/APEX container signatures at API 36 | 262/263 pass; retained Exchange exception below | 243/243 pass |
| APEX payload signature/hash-tree checks | 35/35 pass | 35/35 pass |
| Package/APEX signing continuity | Compared with installed July GApps baseline; no new mismatch | Compared with retained July vanilla target-files; no mismatch |
| Actual image and payload bindings | 991 checks pass | 971 checks pass |
| VINTF and partition sizes | Pass for all five configured vendor SKU cases | Pass for all five configured vendor SKU cases |
| AVB keys, rollback metadata and image verification | Pass; retained configuration | Pass; retained configuration |
| Kernel/config/module files | All 665 retained paths unchanged | All 665 retained paths unchanged |
| Encryption/fstab files | All five retained files unchanged | All five retained files unchanged |

Both full A/B OTAs contain the expected 12 system/boot partitions, have no dependency on old partition contents, include no userdata or metadata partition and request no wipe or downgrade. The GApps dynamic images total 4,454,899,712 bytes; vanilla totals 3,981,627,392 bytes, within the unchanged 9,122,611,200-byte group. Host audio-configuration, pen ABI/helper and keyboard-mapping checks also pass.

### Retained GApps Exchange exception

`com.google.android.gm.exchange` version 508255 fails strict API 36 APK verification because its JAR metadata advertises a v2 signature that is absent. The installed July file, pinned source and candidate have the same SHA-256, `3f65c5fb9da1e341590373497a520c18b286eb44946d0b1b6a8e588e6985acdb`. Complete legacy v1 verification passes, and the signer matches the installed package-manager certificate. This remains an explicit verification exception; the strict GApps APK audit does not have an all-pass result.

## Device results

The exact GApps OTA above was installed through Lineage Recovery over the existing July built-in-GApps installation, from build timestamp `1783566792` to `1794191423`, without formatting userdata or metadata. Recovery verified the package signature and completed the update. A locally validated Magisk 30.7 patch of the matching candidate boot image retained root. The tablet booted on slot B, completed its automatic snapshot merge and passed a second normal reboot. The original credential unlocked encrypted storage on both candidate boots.

| Check | Observed result |
| --- | --- |
| Data retention | Pre-update app identities, UIDs, signing certificates, tracked shared-file hashes, selected settings and all five existing Magisk modules retained. |
| Credential-protected Keystore | The same TEE-backed key signed distinct challenges before the OTA, after the OTA and after the second reboot; all three signatures verified on the host. |
| Microphone capture | MIC and CAMCORDER each returned eight seconds of nonconstant PCM at normal pacing. The July MIC became constant; July CAMCORDER returned silent samples too quickly. |
| Controlled speaker tone | With the stronger reviewed fixture and unchanged detector thresholds, CAMCORDER passed 8/8 analysis windows. MIC passed 4/8, below the required 6/8; its strict tone check remains unsuccessful. Audio mode, volume and mute state were restored. |
| Camera | Front and rear JPEGs decoded at 1920 × 1080. A rear H.264/AAC clip decoded with 147 video frames and about 4.9 seconds of video and nonconstant audio. Camera privacy was restored. |
| Xiaomi keyboard mapping | All 64 arrow/modifier cases passed across four rotations, compared with 16/64 on July. These were Linux input events injected through the existing keyboard's InputReader path; physical keys were not pressed. |
| Pen initialization | The init-managed helper completed with SELinux enforcing in its dedicated, nonpermissive domain. Repeated starts exited successfully without another connection request, and the completion marker stayed unchanged. |
| Screen sleep/wake | The display changed OFF to ON, the controller suspended and resumed, and the registered input devices remained unchanged. The system-suspend success counter stayed at zero during this USB-connected check. |
| Settings and Wi-Fi | The Settings homepage was reviewed in all four rotations with existing gesture navigation, density and font scale; no eligible control/system-bar overlap was found. The current Wi-Fi network validated. Captive-portal login was not exercised. |

The static crash check remains unsuccessful because `tui_comm-1-0` keeps restarting and other one-off service/command exits are present. Every reported exit signature also occurred in the retained July baseline. No Java fatal exception, native fatal signal, app crash/ANR event or kernel fault was found in the captured candidate interval.

## Open test scope and reports

No physical pen is available to the maintainer. Writing, pressure, tilt, buttons, pairing, attachment and pen charging are untested; first-generation pen support is not established. Vanilla has passed host artifact checks, with no tablet installation, boot or upgrade test. Fresh-install and cross-variant migration procedures are not validated in this release.

The Settings/inset overlap and vanilla Wi-Fi login reports remain open. Speech/call quality and noise-suppression or echo-cancellation effectiveness have not been measured; no replacement effect library is shipped. See the [upgrade guide](UPGRADE.md) for the same-variant OTA procedure and separate rooted-update scope.
