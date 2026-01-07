{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  pkg-config,
  alsa-lib,
  bluez,
  curl,
  ffmpeg,
  giflib,
  freetype,
  gettext,
  harfbuzz,
  icu,
  libGL,
  libgit2,
  poppler,
  pugixml,
  SDL2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "emulationstation-de";
  version = "3.4.1";

  src = fetchFromGitLab {
    owner = "liberodark";
    repo = "emulationstation-de";
    tag =  "v3.4.1";
    hash = "sha256-qPSLxzwZlvtvH/XdovzPbqp/Y92DCyQinlv1L1a+N30=";
  };

  postPatch = ''
    # ldd-based detection fails for cross builds
    substituteInPlace CMake/Packages/FindPoppler.cmake \
      --replace-fail 'GET_PREREQUISITES("''${POPPLER_LIBRARY}" POPPLER_PREREQS 1 0 "" "")' ""
  '';

  nativeBuildInputs = [
    cmake
    gettext # msgfmt
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    bluez
    curl
    ffmpeg
    giflib
    freetype
    harfbuzz
    icu
    libGL
    libgit2
    poppler
    pugixml
    SDL2
  ];

  cmakeFlags = [ (lib.cmakeBool "APPLICATION_UPDATER" false) ];

  meta = {
    description = "ES-DE (EmulationStation Desktop Edition) is a frontend for browsing and launching games from your multi-platform collection";
    homepage = "https://es-de.org";
    maintainers = with lib.maintainers; [ liberodark ];
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "es-de";
  };
})