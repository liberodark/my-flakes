{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nixnas";
  version = "1.0.12";

  src = fetchFromGitHub {
    owner = "liberodark";
    repo = "nixnas";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dA+QpiZ++FAygCytUOtZe6RqSu+TZ1LZpM96xIID3+Q=";
  };

  cargoHash = "sha256-REKkmbttcT0cCtvX8kDposAWwoFn1AfzSS7zrZwpcsk=";

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
