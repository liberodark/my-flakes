{
  description = "liberodark packages";

  inputs = {
    # Temporary disable https://github.com/NixOS/nixpkgs/issues/435015
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        citron = pkgs.callPackage ./pkgs/citron/package.nix { };
        suyu = pkgs.callPackage ./pkgs/suyu/package.nix { };
        torzu = pkgs.callPackage ./pkgs/torzu/package.nix { };
        bore-scheduler = pkgs.callPackage ./pkgs/bore-scheduler/package.nix { };
        linux-jovian = {
          linuxPackages_jovian = pkgs.linuxPackagesFor (pkgs.callPackage ./pkgs/linux-jovian/default.nix { });
        };
      in
      {
        packages = {
          # Emulator
          default = torzu;
          citron = citron;
          suyu = suyu;
          torzu = torzu;

          # Kernel
          linuxPackages_6_6_bore = bore-scheduler.linuxPackages_6_6_bore.kernel;
          linuxPackages_6_12_bore = bore-scheduler.linuxPackages_6_12_bore.kernel;
          linuxPackages_6_17_bore = bore-scheduler.linuxPackages_6_17_bore.kernel;
          linuxPackages_jovian = linux-jovian.linuxPackages_jovian.kernel;
        };

        kernelPackages = {
          linuxPackages_6_6_bore = bore-scheduler.linuxPackages_6_6_bore;
          linuxPackages_6_12_bore = bore-scheduler.linuxPackages_6_12_bore;
          linuxPackages_6_17_bore = bore-scheduler.linuxPackages_6_17_bore;
          linuxPackages_jovian = linux-jovian.linuxPackages_jovian;
        };

        apps = {
          default = flake-utils.lib.mkApp {
            drv = torzu;
            name = "yuzu";
          };
          citron = flake-utils.lib.mkApp {
            drv = citron;
            name = "citron";
          };
          suyu = flake-utils.lib.mkApp {
            drv = suyu;
            name = "suyu";
          };
          torzu = flake-utils.lib.mkApp {
            drv = torzu;
            name = "yuzu";
          };
        };
      }
    );
}
