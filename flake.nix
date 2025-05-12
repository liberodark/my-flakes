{
  description = "liberodark packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        torzu = pkgs.callPackage ./pkgs/torzu/package.nix { };
        suyu = pkgs.callPackage ./pkgs/suyu/package.nix { };
      in
      {
        packages = {
          default = torzu;
          torzu = torzu;
          suyu = suyu;
        };

        apps = {
          default = flake-utils.lib.mkApp { drv = torzu; name = "yuzu"; };
          torzu = flake-utils.lib.mkApp { drv = torzu; name = "yuzu"; };
          suyu = flake-utils.lib.mkApp { drv = suyu; name = "suyu"; };
        };
      }
    );
}
