{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nixnas";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "liberodark";
    repo = "nixnas";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tHNZ29QX+RMfmdfIfaX4vDF7bG98fi1o0dEuUYGjdbQ=";
  };

  cargoHash = "sha256-zk1ov4TvY9NEToJdX4CoJ+1G1LSDc0z9Q/ZHV3v3FRQ=";

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
