{
  lib,
  fetchFromGitHub,
  linuxPackages_6_6,
  linuxPackages_6_12,
  linuxPackages_6_14,
  linuxPackages_6_15,
  ...
}:
let
  version = "5.9.6";
  bore-scheduler = fetchFromGitHub {
    owner = "firelzrd";
    repo = "bore-scheduler";
    rev = "cd4af5b36090f3847dc0f584ed23711f6937f890";
    hash = "sha256-ZGDptNltFGMLzQhccHq7pVVauJlc2QUCuWkL0JjHvXU=";
  };

  kernelPatchInfo = {
    "6.6" = { revision = "87"; separator = "-bore"; };
    "6.12" = { revision = "23"; separator = "-bore"; };
    "6.14" = { revision = "9"; separator = "-bore"; };
    "6.15" = { revision = "0"; separator = "-bore"; };
  };

  getPatchesForKernel = kernelVersion:
    let
      patchInfo = kernelPatchInfo.${kernelVersion} or (throw "Unknown kernel version: ${kernelVersion}");
      patchFileName = "0001-linux${kernelVersion}.${patchInfo.revision}${patchInfo.separator}${version}.patch";
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
      {
        name = "bore-scheduler-ext-fix";
        patch = "${bore-scheduler}/patches/additions/0002-sched-ext-coexistence-fix.patch";
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
    kernelPkg.extend (_self: _super: {
      inherit kernel;
    });
in
{
  linuxPackages_6_6_bore = makeKernelPackage linuxPackages_6_6 "6.6";
  linuxPackages_6_12_bore = makeKernelPackage linuxPackages_6_12 "6.12";
  linuxPackages_6_14_bore = makeKernelPackage linuxPackages_6_14 "6.14";
  linuxPackages_6_15_bore = makeKernelPackage linuxPackages_6_15 "6.15";
}
