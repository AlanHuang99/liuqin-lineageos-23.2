# Building the 20261109 maintenance variants

The [release manifest](manifests/release-20261109.xml) pins all 1,174 projects. It includes the October LineageOS 23.2 platform refresh and retains the July device, vendor, kernel and MindTheGapps revisions. The [two maintenance patches](patches/20261109) contain the NFC guards, microphone routes, pen helper/policy, keyboard configuration and explicit variant selection.

## Prepare the source

Run these commands in an empty Android source directory on a configured Linux Android build host:

```bash
repo init -u https://github.com/AlanHuang99/liuqin-lineageos-23.2.git \
  -b refs/tags/20261109 -m manifests/release-20261109.xml --git-lfs
repo sync -c -j8
bash .repo/manifests/scripts/apply-patches.sh "$PWD"
```

The script requires the pinned, clean device and common projects and checks both patches before applying them. The older patches at the top of `patches/` belong to July and must not be applied again. The device uses the retained prebuilt kernel; the pinned kernel source supplies headers and build dependencies. Git LFS is required for the prebuilt payloads.

| Input | Revision or SHA-256 |
| --- | --- |
| Release manifest SHA-256 | `9a8b7ac3b7f6e94249e27f6a7d8eb15a1c2ec928271d89ca2690e77d41376569` |
| Official LineageOS manifest | `3f9562ae369330b3881d5f625cf3f5d97aad9537` |
| `vendor/lineage` | `259ba6626a9e3888e6b60732fb3f829e7de8f26e` |
| `device/xiaomi/liuqin` before patches | `fcc1c87e37a6cee23d95229be3ab57bb6f2e9f6d` |
| `device/xiaomi/sm8450-common` before patches | `d5ab14b2f9c8c1b936bbd71fc71e35678bf7f7c5` |
| `device/xiaomi/liuqin-kernel` | `cc037e1512ab14647e9b26dbb39dc259c4bc9944` |
| `vendor/gapps` | `f8cdcffc2fb9181b8cc5a9b02d4b5908b64e5cdd` |

The public manifest uses absolute public remotes. Its project paths and revisions match the resolved build inputs. A rebuild gets its own timestamp and artifact hashes.

## Select a variant

Set `LIUQIN_GAPPS_VARIANT` before `lunch`. Valid values are `gapps` and `vanilla`; an unset or invalid value stops configuration. GApps requires the pinned `vendor/gapps` tree. Its presence alone does not enable Google apps. Leave `WITH_GMS` unset.

Build variants sequentially with separate physical output directories. From the source root, run in Bash:

```bash
systemd-run --user --scope -p MemoryMax=60G -p MemorySwapMax=0 \
  bash --noprofile --norc -c '
    set -e
    unset WITH_GMS
    export LIUQIN_GAPPS_VARIANT=gapps
    export OUT_DIR=out-gapps
    export GOMEMLIMIT=20GiB
    source build/envsetup.sh
    lunch lineage_liuqin-bp4a-userdebug
    m -j16 bacon target-files-package
  '
```

For vanilla, change the selector to `vanilla` and the output directory to `out-vanilla`. Size the memory cap and parallelism for the host, leaving capacity for other services. The release builds used separate physical outputs; a stable logical `out` path allowed a copied compile cache to be reused after a separate vanilla `installclean`.

## Retain and verify artifacts

Keep the OTA ZIP, matching target-files ZIP, images, resolved manifest and build log for each variant. OTAs are under `OUT_DIR/target/product/liuqin/`; target-files archives are under its `obj/PACKAGING/target_files_intermediates/` directory. Add `-gapps` or `-vanilla` to a copy of the OTA filename before calculating release checksums. Keep the device identity and signing configuration unchanged.

Verify whole OTA and payload signatures with the matching source `check_ota_package_signature` tool and host `delta_generator`. Verify APK/APEX signing continuity, APEX payload keys, VINTF, partition sizes, actual image/payload contents and the variant package set. Compare kernel/modules and fstab encryption settings with the retained baseline. Record platform and vendor SPL separately. The full OTA metadata does not enforce vanilla/GApps matching.

The release uses the retained July test-key configuration. The exact [release validation](RELEASE_NOTES.md#host-validation) records both successful checks and the unchanged GApps Exchange APK strict-verification exception. Device results are recorded separately in the same notes.
