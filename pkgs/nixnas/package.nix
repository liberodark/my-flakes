{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nixnas";
  version = "1.0.7";

  src = fetchFromGitHub {
    owner = "liberodark";
    repo = "nixnas";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NZaf3OjyzfIEV2CW9QemTHySU6zMU74v/sFAms6Nvrw=";
  };

  cargoHash = "sha256-MUi4IhXjXyXLgUbbVeeBgUxzU37Zr+c5YjlteaGmVRM=";

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
