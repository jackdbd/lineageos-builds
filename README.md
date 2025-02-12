# LineageOS build for Xiaomi Redmi Note 7 (code name lavender)

> [!WARNING]
> **Work in progress**: these instructions are incomplete. I managed to download the LineageOS source code, the device-specific configuration and kernel, but I haven't yet figure out how to build LineageOS on NixOS.

## Preparation

Run these devenv scripts to [create the directories](https://wiki.lineageos.org/devices/lavender/build/#create-the-directories), [install the `repo` command](https://wiki.lineageos.org/devices/lavender/build/#install-the-repo-command) (it's an executable Python script), [initialize the LineageOS source repository](https://wiki.lineageos.org/devices/lavender/build/#initialize-the-lineageos-source-repository) and [download the LineageOS source code](https://wiki.lineageos.org/devices/lavender/build/#download-the-source-code).

```sh
create-directories
install-repo
init-lineage-source-repo
download-lineage-source
```

## [Prepare the device-specific code](https://wiki.lineageos.org/devices/lavender/build/#prepare-the-device-specific-code)

Use this `sd` command to replace `/bin/pwd` in `~/android/lineage/build/envsetup.sh`.

```sh
sd ' /bin/pwd' "$(which pwd)" ~/android/lineage/build/envsetup.sh
```

Open `~/android/lineage/build/envsetup.sh` and replace this line...

```sh
export ANDROID_BUILD_TOP=$(gettop)
```

...with these lines:

```sh
export TOP="/home/jack/android/lineage";
export ANDROID_BUILD_TOP="/home/jack/android/lineage";
```

Note: I tried using `~/android/lineage` but it didn't work. I had to use the full path.

You could maybe try this command instead of replacing that line manually (I haven't tested it):

```sh
sd 'export ANDROID_BUILD_TOP=\$\((.+)\)' 'export ANDROID_BUILD_TOP="/home/jack/android/lineage"' ~/android/lineage/build/envsetup.sh
```

From `~/android/lineage`, run:

```sh
export TOP="/home/jack/android/lineage"
export ANDROID_BUILD_TOP="/home/jack/android/lineage"
source build/envsetup.sh
breakfast lavender
```

This will download your device’s [device specific configuration](https://github.com/LineageOS/android_device_xiaomi_lavender) and [kernel](https://github.com/LineageOS/android_kernel_xiaomi_sdm660).

## [Start the build](https://wiki.lineageos.org/devices/lavender/build/#start-the-build)

> [!CAUTION]
> I am stuck at this step.

```sh
source ~/android/lineage/build/soong/scripts/microfactory.bash
./home/jack/android/lineage/build/soong/scripts/microfactory.bash
```

The file `~/android/lineage/build/soong/scripts/microfactory.bash` contains a function `soong_build_go` that - once called - runs this command:

```sh
build_go soong_ui android/soong/cmd/soong_ui
```

Where:

- `soong_ui` is the name of the requested binary
- `android/soong/cmd/soong_ui` is the package name

Build Microfactory?

```sh
${GOROOT}bin/go build \
  -tags netgo \
  -ldflags '-extldflags \"-static\"' \
  -o ${BUILDDIR}/microfactory_$(uname) \
  ${BLUEPRINTDIR}/microfactory/microfactory.go
```

Then use Microfactory to build another binary?

> [!NOTE]
> Microfactory is a [tool to incrementally compile a go program](https://android.googlesource.com/platform/build/blueprint/+/refs/heads/master/microfactory/microfactory.go).

The `soong_build_go` function builds a dynamic executable. I cannot run that on NixOS without using something like [nix-ld](https://nix.dev/guides/faq#how-to-run-non-nix-executables).

## References

- [Build LineageOS for Xiaomi Redmi Note 7 (lavender)](https://wiki.lineageos.org/devices/lavender/build/)
