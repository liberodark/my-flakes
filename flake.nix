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
        # Packages from ./pkgs/yuzu
        yuzuPkgs = pkgs.callPackage ./pkgs/yuzu { };
        packageNames = builtins.attrNames yuzuPkgs;
        getPkg = name: builtins.getAttr name yuzuPkgs;
        # Helper: use mainProgram if present, else name
        mkApp = name:
          let pkg = getPkg name;
          in flake-utils.lib.mkApp {
            drv = pkg;
            name = (pkg.meta.mainProgram or name);
          };
      in {
        packages = builtins.listToAttrs (
          map (n: { name = n; value = getPkg n; }) packageNames
        );

        apps = builtins.listToAttrs (
          map (n: { name = n; value = mkApp n; }) packageNames
        );
      }
    );
}