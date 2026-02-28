{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nixnas";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "liberodark";
    repo = "nixnas";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OUmfG3hF5cuRctZlgk0gTTnKOZjPlWManLdYLtI90c4=";
  };

  cargoHash = "sha256-rkwk975KreU2Rp6X3gDXAw7IdtBpG1BVy4BtrReOU5Q=";

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
