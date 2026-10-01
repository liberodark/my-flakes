{
  lib,
  fetchFromGitHub,
  linuxPackages_6_12,
  linuxPackages_6_18,
  ...
}:
let
  version = "6.8.0";
  bore-scheduler = fetchFromGitHub {
    owner = "firelzrd";
    repo = "bore-scheduler";
    rev = "56e92d8af94a9a1c2d3464349e0a78167cd884c2";
    hash = "sha256-6GARHZ+AEYGsKckix5zXJFRHs/pHKRO8DTVOO/ziCBE=";
  };

  kernelPatchInfo = {
    "6.12" = {
      revision = "37";
      separator = "-bore";
    };
    "6.18" = {
      revision = "48";
      separator = "-bore";
    };
  };

  getPatchesForKernel =
    kernelVersion:
    let
      patchInfo = kernelPatchInfo.${kernelVersion} or (throw "Unknown kernel version: ${kernelVersion}");
      patchFileName = "0001-linux${kernelVersion}${
        if patchInfo.revision != "" then ".${patchInfo.revision}" else ""
      }${patchInfo.separator}-${version}.patch";
    in
    [
      {
        name = "bore-scheduler";
        patch = "${bore-scheduler}/patches/stable/${patchFileName}";
      }
    ];

  makeKernelPackage =
    kernelPkg: kernelVersion:
    let
      kernel = kernelPkg.kernel.override {
        structuredExtraConfig = with lib.kernel; {
          SCHED_BORE = yes;
        };
        kernelPatches = getPatchesForKernel kernelVersion;
        extraMeta = {
          branch = kernelVersion;
          maintainers = with lib.maintainers; [ liberodark ];
          description = "Linux kernel with BORE (Burst-Oriented Response Enhancer) CPU scheduler ${version}";
        };
      };
    in
    kernelPkg.extend (
      _self: _super: {
        inherit kernel;
      }
    );
in
{
  linuxPackages_6_12_bore = makeKernelPackage linuxPackages_6_12 "6.12";
  linuxPackages_6_18_bore = makeKernelPackage linuxPackages_6_18 "6.18";
}
