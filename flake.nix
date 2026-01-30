{
  description = "liberodark packages";

  inputs = {
    # Temporary disable https://github.com/NixOS/nixpkgs/issues/435015
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
        torzu-next = pkgs.callPackage ./pkgs/torzu-next/package.nix { };
        emulationstation-de = pkgs.callPackage ./pkgs/emulationstation-de/package.nix { };
        nixnas = pkgs.callPackage ./pkgs/nixnas/package.nix { };
        bore-scheduler = pkgs.callPackage ./pkgs/bore-scheduler/package.nix { };
        linux-kctf = pkgs.callPackage ./pkgs/linux-kctf/package.nix { };
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
          torzu-next = torzu-next;

          # Frontend
          emulationstation-de = emulationstation-de;

          # NAS
          nixnas = nixnas;

          # Kernel
          linuxPackages_6_6_bore = bore-scheduler.linuxPackages_6_6_bore.kernel;
          linuxPackages_6_12_bore = bore-scheduler.linuxPackages_6_12_bore.kernel;
          linuxPackages_6_18_bore = bore-scheduler.linuxPackages_6_18_bore.kernel;
          linuxPackages_6_12_kctf = linux-kctf.linuxPackages_6_12_kctf.kernel;
          linuxPackages_jovian = linux-jovian.linuxPackages_jovian.kernel;
        };

        kernelPackages = {
          linuxPackages_6_6_bore = bore-scheduler.linuxPackages_6_6_bore;
          linuxPackages_6_12_bore = bore-scheduler.linuxPackages_6_12_bore;
          linuxPackages_6_18_bore = bore-scheduler.linuxPackages_6_18_bore;
          linuxPackages_6_12_kctf = linux-kctf.linuxPackages_6_12_kctf;
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
          torzu-next = flake-utils.lib.mkApp {
            drv = torzu-next;
            name = "yuzu";
          };
          emulationstation-de = flake-utils.lib.mkApp {
            drv = emulationstation-de;
            name = "es-de";
          };
          nixnas = flake-utils.lib.mkApp {
            drv = nixnas;
            name = "nixnas-daemon";
          };
        };
      }
    );
}
