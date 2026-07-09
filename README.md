# LineageOS 23.2 for Xiaomi Pad 6 Pro (liuqin)

Unofficial LineageOS 23.2 (Android 16) builds for the Xiaomi Pad 6 Pro, codename `liuqin` (model 23046RP50C, SM8475 / Snapdragon 8+ Gen 1, WiFi-only).

This is an unofficial community build. It is not affiliated with, endorsed by, or supported by LineageOS or Xiaomi. Flashing custom firmware carries risk, including data loss; proceed only if you understand how to recover your device.

## Status

Built from source on 2026-07-09 and booted on a retail liuqin (bootloader unlocked). Checked on-device:

- Boots to setup; SELinux enforcing; file-based encryption active.
- Display: 1800x2880 internal panel running at 144 Hz, with 120/90/60/50/48/30 Hz modes and HDR types reported.
- Auto-rotation works (accelerometer); the gyroscope and ambient-light sensors enumerate.
- WiFi scans 2.4 and 5 GHz networks; Bluetooth turns on; the primary audio output HAL initializes.
- Cameras enumerate; the camera app captured a 12 MP photo.
- The LineageOS recovery boots and `adb sideload` is available.

Not exhaustively tested: WiFi/Bluetooth throughput and pairing, hardware video decode, GPU under load, the stylus, GPS, and audio playback quality. Please report anything you find.

There is no NFC or secure element on this device, so those features are intentionally absent (see "SecureElement / NFC fix" below).

## Downloads

Builds are attached to the [Releases](../../releases) page:

- `lineage-23.2-<date>-UNOFFICIAL-liuqin.zip` — installable package (recovery sideload).
- `recovery.img` — LineageOS recovery, flashed first via fastboot.
- `boot.img`, `dtbo.img`, `vendor_boot.img`, `vbmeta.img`, `vbmeta_system.img` — additional fastboot images.
- `SHA256SUMS` — checksums for all of the above.

Builds are vanilla (no Google apps). If you want the Play Store and Google services, sideload a Google apps package (for example MindTheGapps arm64 for Android 16) right after the ROM, before first boot.

## Install (recovery sideload)

You need an unlocked bootloader and `adb` / `fastboot` on a computer. This erases user data. Flashing an unofficial build is at your own risk.

1. Reboot to the bootloader: `adb reboot bootloader`.
2. Flash the LineageOS recovery to both slots, and disable Android Verified Boot so the device accepts the build:
   ```
   fastboot flash recovery_a recovery.img
   fastboot flash recovery_b recovery.img
   fastboot --disable-verity --disable-verification flash vbmeta_a vbmeta.img
   fastboot --disable-verity --disable-verification flash vbmeta_b vbmeta.img
   ```
3. Reboot to recovery: `fastboot reboot recovery` (or hold Volume Up + Power).
4. In LineageOS recovery: Factory reset → Format data / factory reset.
5. Apply update → Apply from ADB, then on the computer:
   `adb sideload lineage-23.2-<date>-UNOFFICIAL-liuqin.zip`
6. Optionally sideload a Google apps zip the same way, before rebooting.
7. Reboot to system. First boot takes a few minutes.

Verified on liuqin: the images boot, and the recovery boots with `adb sideload` available. If the recovery screen does not render for you, you can format data from the bootloader instead with `fastboot -w`, then enter "Apply from ADB" and sideload as above.

## Build from source

Replace `<account>/<repo>` with this repository.

```bash
mkdir liuqin && cd liuqin
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs
mkdir -p .repo/local_manifests
curl -Lo .repo/local_manifests/liuqin.xml \
  https://raw.githubusercontent.com/<account>/<repo>/main/local_manifests/liuqin.xml
repo sync -c -j8

# Apply the NFC/SecureElement fix (also proposed upstream to Sickyman678):
curl -L https://raw.githubusercontent.com/<account>/<repo>/main/patches/0001-sm8450-common-guard-nfc-se-on-TARGET_HAS_NO_NFC.patch \
  | git -C device/xiaomi/sm8450-common apply
curl -L https://raw.githubusercontent.com/<account>/<repo>/main/patches/0002-liuqin-set-TARGET_HAS_NO_NFC.patch \
  | git -C device/xiaomi/liuqin apply

source build/envsetup.sh
lunch lineage_liuqin-bp4a-userdebug
mka bacon
```

Output is in `out/target/product/liuqin/`. The device tree uses a prebuilt kernel (`device/xiaomi/liuqin-kernel`); the kernel source is synced only for headers. Once the fix is merged upstream, the `git apply` steps are no longer needed.

## SecureElement / NFC fix

The shared `sm8450-common` tree installs the `android.hardware.se.omapi.uicc/ese` feature permission files on every device. On liuqin there is no NFC controller and no secure element, so `SecureElementService` binds a HAL that does not exist and the system writes an ANR roughly every 20 seconds (`executing service com.android.se/.SecureElementService, waited 20006ms`).

The `patches/` directory adds a `TARGET_HAS_NO_NFC` guard (mirroring the tree's existing `TARGET_HAS_NO_TELEPHONY` guard) that skips the NFC and SecureElement packages and feature files on liuqin. The builds here include this fix.

If you are already running a build without the fix, `modules/liuqin_no_se.zip` is a Magisk module that neutralizes the two feature files at boot without modifying `/vendor`.

## Credits

- [LineageOS](https://github.com/LineageOS) — the platform, `hardware/xiaomi`, and the sm8450 kernel source, devicetrees, and modules.
- [Sickyman678](https://github.com/Sickyman678) — the liuqin device tree, prebuilt kernel, sm8450-common tree, and vendor blobs these builds are based on.
- [Xiaomi-SM8475](https://github.com/Xiaomi-SM8475) — the Paranoid Android (vauxite) liuqin device tree that Sickyman678's device tree is forked from.

## License

Build configuration and the manifest/patches in this repository are provided under the Apache License 2.0, matching the upstream device trees. Proprietary vendor blobs remain under their respective licenses and are not redistributed here.
