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
        inherit (pkgs.callPackage ./pkgs/yuzu { })
          citron
          torzu
          suyu
          sudachi
          eden
          ;
      in
      {
        packages = {
          default = torzu;
          citron = citron;
          torzu = torzu;
          suyu = suyu;
          sudachi = sudachi;
          eden = eden;

        };

        apps = {
          default = flake-utils.lib.mkApp { drv = torzu; name = "yuzu"; };
          citron = flake-utils.lib.mkApp { drv = citron; name = "citron"; };
          torzu = flake-utils.lib.mkApp { drv = torzu; name = "yuzu"; };
          suyu = flake-utils.lib.mkApp { drv = suyu; name = "suyu"; };
          sudachi = flake-utils.lib.mkApp { drv = sudachi; name = "yuzu"; };
          eden = flake-utils.lib.mkApp { drv = eden; name = "eden"; };
        };
      }
    );
}
