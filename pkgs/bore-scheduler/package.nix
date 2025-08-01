{
  lib,
  fetchFromGitHub,
  linuxPackages_6_6,
  linuxPackages_6_12,
  linuxPackages_6_15,
  linuxPackages_6_16,
  ...
}:
let
  version = "6.1.0";
  bore-scheduler = fetchFromGitHub {
    owner = "firelzrd";
    repo = "bore-scheduler";
    rev = "827be54f9e433f44accc4cdd5ee476294cc77e3b";
    hash = "sha256-p+JiCRqqadONor+/kFnsMthfN3uSqU9h/H9vlyJQKR0=";
  };

  kernelPatchInfo = {
    "6.6" = {
      revision = "97";
      separator = "-bore";
    };
    "6.12" = {
      revision = "37";
      separator = "-bore";
    };
    "6.15" = {
      revision = "6";
      separator = "-bore";
    };
    "6.16" = {
      revision = "";
      separator = "-rc5-bore";
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
        patch = "${bore-scheduler}/patches/stable/linux-${kernelVersion}-bore/${patchFileName}";
      }
      {
        name = "bore-scheduler-smt";
        patch = "${bore-scheduler}/patches/stable/linux-${kernelVersion}-bore/0002-sched-fair-Prefer-full-idle-SMT-cores.patch";
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
  linuxPackages_6_6_bore = makeKernelPackage linuxPackages_6_6 "6.6";
  linuxPackages_6_12_bore = makeKernelPackage linuxPackages_6_12 "6.12";
  linuxPackages_6_15_bore = makeKernelPackage linuxPackages_6_15 "6.15";
  linuxPackages_6_16_bore = makeKernelPackage linuxPackages_6_16 "6.16";
}
