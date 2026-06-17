{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nix-output-monitor";
  version = "1.0.0-unstable-2025-06-17";

  src = fetchFromGitHub {
    owner = "liberodark";
    repo = "nom-rs";
    rev = "524a1656bafd10dd61381f134392e477928009fa";
    hash = "sha256-L/Sw0MRCdj1JtlUieaff8+tgotW1FN3juvJP75EbhzE=";
  };

  cargoHash = "sha256-Lb54nGPZQ073VnmHjURMx5r7AD+MNHIupUV6bfKIClY=";
  
  doCheck = true;

  postInstall = ''
    ln -s nom $out/bin/nom-build
    ln -s nom $out/bin/nom-shell
  '';

  meta = {
    description = "Processes output of Nix commands to show helpful and pretty information";
    homepage = "https://github.com/liberodark/nom-rs";
    license = lib.licenses.agpl3Plus;
    mainProgram = "nom";
    platforms = lib.platforms.unix;
  };
})
