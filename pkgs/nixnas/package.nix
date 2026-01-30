{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nixnas";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "liberodark";
    repo = "nixnas";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aK43Jd6MG3VvJTlv3JelTyLpomClEgZ9higxi2eXckM=";
  };

  cargoHash = "sha256-kSAEGGXOSVOtR2sJDTiOw3Q6AHacmeIxgofZlx/7m1I=";

  #nativeInstallCheckInputs = [
  #  versionCheckHook
  #];
  #versionCheckProgramArg = "--version";
  doInstallCheck = true;

  meta = {
    description = "NixOS NAS management daemon with web interface";
    homepage = "https://github.com/liberodark/nixnas";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ liberodark ];
    platforms = lib.platforms.linux;
    mainProgram = "nixnas-daemon";
  };
})
