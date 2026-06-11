{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nixnas";
  version = "1.0.14";

  src = fetchFromGitHub {
    owner = "liberodark";
    repo = "nixnas";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PXrUGIjdg4A9Cbi9VnWEfpNZ9w+rNpbaUuTFfjq3xQE=";
  };

  cargoHash = "sha256-ODZmrGBEm37PYGS1mzFGddAMM8YaLi+92Szil+CZHHw=";

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  versionCheckProgramArg = "--version";
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
