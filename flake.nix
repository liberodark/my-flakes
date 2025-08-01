{
  description = "liberodark packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
        torzu = pkgs.callPackage ./pkgs/torzu/package.nix { };
        suyu = pkgs.callPackage ./pkgs/suyu/package.nix { };
        bore-scheduler = pkgs.callPackage ./pkgs/bore-scheduler/package.nix { };
        linux-jovian = {
          linuxPackages_jovian = pkgs.linuxPackagesFor (pkgs.callPackage ./pkgs/linux-jovian/default.nix { });
        };
      in
      {
        packages = {
          # Emulator
          default = torzu;
          torzu = torzu;
          suyu = suyu;

          # Kernel
          linuxPackages_6_6_bore = bore-scheduler.linuxPackages_6_6_bore.kernel;
          linuxPackages_6_12_bore = bore-scheduler.linuxPackages_6_12_bore.kernel;
          linuxPackages_6_15_bore = bore-scheduler.linuxPackages_6_15_bore.kernel;
          linuxPackages_6_16_bore = bore-scheduler.linuxPackages_6_16_bore.kernel;
          linuxPackages_jovian = linux-jovian.linuxPackages_jovian.kernel;
        };

        kernelPackages = {
          linuxPackages_6_6_bore = bore-scheduler.linuxPackages_6_6_bore;
          linuxPackages_6_12_bore = bore-scheduler.linuxPackages_6_12_bore;
          linuxPackages_6_15_bore = bore-scheduler.linuxPackages_6_15_bore;
          linuxPackages_6_16_bore = bore-scheduler.linuxPackages_6_16_bore;
          linuxPackages_jovian = linux-jovian.linuxPackages_jovian;
        };

        apps = {
          default = flake-utils.lib.mkApp {
            drv = torzu;
            name = "yuzu";
          };
          torzu = flake-utils.lib.mkApp {
            drv = torzu;
            name = "yuzu";
          };
          suyu = flake-utils.lib.mkApp {
            drv = suyu;
            name = "suyu";
          };
        };
      }
    );
}
