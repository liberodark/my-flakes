{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchzip,
  abseil-cpp,
  alsa-lib,
  cmake,
  cxxopts,
  dbus,
  fmt,
  freetype,
  libGL,
  libglvnd,
  libjpeg_turbo,
  libpulseaudio,
  libusb1,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  libxscrnsaver,
  libxtst,
  makeWrapper,
  ninja,
  nlohmann_json,
  pkg-config,
  python3,
  sdl3,
  tracy,
  vulkan-loader,
  wayland,
  xxhash,
  zstd,
}:

let
  auroraSrc = fetchFromGitHub {
    owner = "encounter";
    repo = "aurora";
    rev = "63606a43265a3bc18dafd500ab4d7a2108f109e6";
    hash = "sha256-xBvnAwGwNzav67Ac6oUz7RqDUwqgL2bsME3OOMn8Tqw=";
  };
  dawnSrc = fetchzip {
    url = "https://github.com/encounter/dawn-build/releases/download/v20260423.175430/dawn-linux-x86_64.tar.gz";
    hash = "sha256-HXfKTLHtMPwupnFnaflCARtXVPuS/0PoCePXidjE5xs=";
    stripRoot = false;
  };
  nodSrc = fetchzip {
    url = "https://github.com/encounter/nod/releases/download/v2.0.0-alpha.8/libnod-linux-x86_64.tar.gz";
    hash = "sha256-mUqvLsbsqaZ+HAjMmHYPYO+MgtanGRTw7Gzn5uXR5rE=";
    stripRoot = false;
  };
  imguiSrc = fetchFromGitHub {
    owner = "ocornut";
    repo = "imgui";
    tag = "v1.91.9b-docking";
    hash = "sha256-mQOJ6jCN+7VopgZ61yzaCnt4R1QLrW7+47xxMhFRHLQ=";
  };
  sqliteSrc = fetchzip {
    url = "https://sqlite.org/2026/sqlite-amalgamation-3510300.zip";
    hash = "sha256-pNMR8zxaaqfAzQ0AQBOXMct4usdjey1Q0Gnitg06UhM=";
  };
  rmluiSrc = fetchzip {
    url = "https://github.com/mikke89/RmlUi/archive/f9b8c9e2935d5df2c7dff2c190d3968e99b0c3dc.tar.gz";
    hash = "sha256-g4O/JZUrrcseOz8o2QJRt+2CeuiLnVeuDJc906xvuIg=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dusk";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "TwilitRealm";
    repo = "dusk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lTvtYeQsptpjI3RuyfmlVKkdfxVMgMZkjv/KUzy1h2k=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    cmake
    makeWrapper
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    abseil-cpp
    alsa-lib
    cxxopts
    dbus
    fmt
    freetype
    libGL
    libglvnd
    libjpeg_turbo
    libpulseaudio
    libusb1
    libx11
    libxcb
    libxcursor
    libxi
    libxkbcommon
    libxrandr
    libxscrnsaver
    libxtst
    nlohmann_json
    sdl3
    tracy
    vulkan-loader
    wayland
    xxhash
    zstd
  ];

  postUnpack = ''
    chmod -R u+w "$sourceRoot"
    mkdir -p "$sourceRoot/extern/aurora"
    cp -rT --no-preserve=mode "${auroraSrc}" "$sourceRoot/extern/aurora"
    sed -i '/add_subdirectory(tests)/d' "$sourceRoot/extern/aurora/CMakeLists.txt"
  '';

  cmakeBuildType = "RelWithDebInfo";

  cmakeFlags = [
    (lib.cmakeFeature "DUSK_WC_DESCRIBE" "v${finalAttrs.version}")
    (lib.cmakeBool "CMAKE_DISABLE_FIND_PACKAGE_Git" true)
    (lib.cmakeBool "FETCHCONTENT_FULLY_DISCONNECTED" true)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_CXXOPTS" cxxopts.src.outPath)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_JSON" nlohmann_json.src.outPath)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_DAWN_PREBUILT" dawnSrc.outPath)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_XXHASH" xxhash.src.outPath)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_FMT" fmt.src.outPath)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_TRACY" tracy.src.outPath)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_NOD_PREBUILT" nodSrc.outPath)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_FREETYPE" freetype.src.outPath)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_ZSTD" zstd.src.outPath)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_SQLITE3" sqliteSrc.outPath)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_IMGUI" imguiSrc.outPath)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_RMLUI" rmluiSrc.outPath)
    (lib.cmakeFeature "AURORA_SDL3_PROVIDER" "system")
    (lib.cmakeFeature "AURORA_NOD_PROVIDER" "package")
    (lib.cmakeBool "CMAKE_CROSSCOMPILING" true)
    (lib.cmakeBool "DUSK_ENABLE_SENTRY_NATIVE" false)
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 dusk             $out/share/dusk/dusk
    cp -r ../res                    $out/share/dusk/res
    mkdir -p $out/bin
    ln -s ../share/dusk/dusk        $out/bin/dusk

    install -Dm644 \
      ../platforms/freedesktop/dusk.desktop \
      $out/share/applications/dusk.desktop

    substituteInPlace $out/share/applications/dusk.desktop \
      --replace-fail "Icon=dusk" "Icon=dev.twilitrealm.dusk"

    for size in 16x16 32x32 48x48 64x64 128x128 256x256 512x512 1024x1024; do
      install -Dm644 \
        ../platforms/freedesktop/$size/apps/dusk.png \
        $out/share/icons/hicolor/$size/apps/dev.twilitrealm.dusk.png
    done

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/share/dusk/dusk \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          vulkan-loader
          libGL
          libglvnd
          alsa-lib
          libpulseaudio
        ]
      }"
  '';

  meta = {
    description = "Reverse-engineered reimplementation of The Legend of Zelda: Twilight Princess";
    homepage = "https://github.com/TwilitRealm/dusk";
    changelog = "https://github.com/TwilitRealm/dusk/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.cc0;
    mainProgram = "dusk";
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ liberodark ];
  };
})
