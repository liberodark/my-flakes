{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nixnas";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "liberodark";
    repo = "nixnas";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CuqMVwdf8UYYaY/ofKHVu9rEBAyqmagixZBNr13XXXk=";
  };

  cargoHash = "sha256-Zcut3DLMXe6iYWWMHhSTmEKtuknUBYTbzkRW1Gc4k54=";

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
