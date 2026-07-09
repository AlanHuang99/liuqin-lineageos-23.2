# LineageOS 23.2 for Xiaomi Pad 6 Pro (liuqin)

Unofficial LineageOS 23.2 (Android 16) builds for the Xiaomi Pad 6 Pro, codename `liuqin` (model 23046RP50C, SM8475 / Snapdragon 8+ Gen 1, WiFi-only).

This is an unofficial community build. It is not affiliated with, endorsed by, or supported by LineageOS or Xiaomi. Flashing custom firmware carries risk, including data loss; proceed only if you understand how to recover your device.

## Status

Built from source on 2026-07-09 and booted on a retail liuqin with the bootloader unlocked. The following were checked on-device:

- Boots to setup; SELinux enforcing; file-based encryption active.
- Display: 1800x2880 internal panel, 144 Hz (also 120/90/60/50/48/30), HDR modes reported.
- WiFi (scan and associate), Bluetooth, sensors (accelerometer, gyroscope, ambient light), speaker audio.
- Cameras enumerate and the camera app previews.
- Hardware video, GPU, and the stylus were not exhaustively tested. Report issues you find.

There is no NFC or secure element on this device, so those features are intentionally absent (see "SecureElement/NFC fix" below).

## Downloads

Builds are attached to the [Releases](../../releases) page:

- `lineage-23.2-<date>-UNOFFICIAL-liuqin.zip` — installable package (recovery sideload).
- `boot.img`, `dtbo.img`, `vendor_boot.img`, `recovery.img`, `vbmeta.img` — fastboot images.

Builds are vanilla (no Google apps). Install a Google apps package (for example MindTheGapps arm64 for Android 16) yourself if you want the Play Store and Google services, before first boot.

## Install (recovery sideload)

You need an unlocked bootloader and `adb` / `fastboot` on a computer.

1. Reboot to the bootloader: `adb reboot bootloader`.
2. Flash the recovery and boot images to both slots:
   ```
   fastboot flash boot_a boot.img;         fastboot flash boot_b boot.img
   fastboot flash dtbo_a dtbo.img;         fastboot flash dtbo_b dtbo.img
   fastboot flash vendor_boot_a vendor_boot.img; fastboot flash vendor_boot_b vendor_boot.img
   fastboot flash recovery_a recovery.img; fastboot flash recovery_b recovery.img
   fastboot --disable-verity --disable-verification flash vbmeta_a vbmeta.img
   fastboot --disable-verity --disable-verification flash vbmeta_b vbmeta.img
   ```
3. Reboot to recovery (hold Volume Up + Power, or `fastboot reboot recovery`).
4. In LineageOS recovery: Factory reset → Format data/factory reset.
5. Apply update → Apply from ADB, then on the computer:
   `adb sideload lineage-23.2-<date>-UNOFFICIAL-liuqin.zip`
6. Optionally sideload a Google apps zip the same way before rebooting.
7. Reboot to system.

First boot takes a few minutes.

## Build from source

```bash
mkdir liuqin && cd liuqin
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs
git clone https://github.com/<your-account>/<this-repo> .repo/local_manifests_src
cp .repo/local_manifests_src/local_manifests/liuqin.xml .repo/local_manifests/
repo sync -c -j8
# apply the NFC/SecureElement fix (also proposed upstream):
( cd device/xiaomi/sm8450-common && git apply /path/to/patches/0001-*.patch )
( cd device/xiaomi/liuqin       && git apply /path/to/patches/0002-*.patch )
source build/envsetup.sh
lunch lineage_liuqin-bp4a-userdebug
mka bacon
```

Output is in `out/target/product/liuqin/`. The device tree uses a prebuilt kernel (`device/xiaomi/liuqin-kernel`); the kernel source is synced only for headers.

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
