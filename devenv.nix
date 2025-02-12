{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  enterShell = ''
    versions
  '';

  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  env = {
    TOP = "/home/jack/android/lineage";
    ANDROID_BUILD_TOP = "/home/jack/android/lineage";
    BUILDDIR = "/home/jack/android/lineage/out";
    # Building LineageOS requires $HOME/bin to be in the PATH
    # https://wiki.lineageos.org/devices/lavender/build/#put-the-bin-directory-in-your-path-of-execution
    BLUEPRINTDIR = "/home/jack/android/lineage/build/blueprint";
    # This ensures we obtain a statically-linked binary when we compile a go program
    CGO_ENABLED = 0;
    EXTRA_ARGS = "-pkg-path android/soong=/home/jack/android/lineage/build/soong -pkg-path github.com/golang/protobuf=/home/jack/android/lineage/external/golang-protobuf";
    MICROFACTORY_BIN = "/home/jack/android/lineage/out/microfactory_Linux";
    PATH = "${builtins.getEnv "HOME"}/bin:$PATH";
    SRCDIR = "/home/jack/android/lineage";
    # https://wiki.lineageos.org/devices/lavender/build/#turn-on-caching-to-speed-up-build
    USE_CCACHE = 1;
  };

  # https://devenv.sh/languages/
  languages = {
    go.enable = true;
    java.enable = true;
    nix.enable = true;
    python.enable = true;
  };

  # https://devenv.sh/packages/
  packages = with pkgs; [
    android-tools # it includes: adb, fastboot
    libtinfo # it includes: libncurses5
    bison
    ccache
    curl
    git
    git-lfs
    lzop
    pngcrush
    rsync
    schedtool
    sd # sed replacement
  ];

  # https://devenv.sh/reference/options/#pre-commit
  pre-commit.hooks = {
    alejandra.enable = true;
    # deadnix.enable = true;
  };

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/scripts/
  scripts = {
    # https://wiki.lineageos.org/devices/lavender/build/#create-the-directories
    create-directories.exec = ''
      mkdir -p ~/bin
      mkdir -p ~/android/lineage
    '';
    # https://wiki.lineageos.org/devices/lavender/build/#download-the-source-code
    download-lineage-source.exec = ''
      cd ~/android/lineage
      repo sync
    '';
    # https://wiki.lineageos.org/devices/lavender/build/#initialize-the-lineageos-source-repository
    init-lineage-source-repo.exec = ''
      cd ~/android/lineage
      repo init -u https://github.com/LineageOS/android.git -b lineage-18.1 --git-lfs --no-clone-bundle
    '';
    # https://wiki.lineageos.org/devices/lavender/build/#install-the-repo-command
    install-repo.exec = ''
      curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
      chmod a+x ~/bin/repo
    '';
    # https://wiki.lineageos.org/devices/lavender/build/#prepare-the-device-specific-code
    prepare-device-specific-code.exec = ''
      sd ' /bin/pwd' "$(which pwd)" ~/android/lineage/build/envsetup.sh
      cd ~/android/lineage
      source build/envsetup.sh
      breakfast lavender
    '';
    versions.exec = ''
      echo "=== Versions ==="
      echo ""
      adb --version
      echo ""
      bison --version
      echo ""
      ccache --version
      echo ""
      curl --version
      echo ""
      fastboot --version
      echo ""
      git-lfs --version
      echo ""
      go version
      echo ""
      java -version
      echo ""
      python --version
      echo "=== === ==="
    '';
  };

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # See full reference at https://devenv.sh/reference/options/
}
