{
  lib,
  fetchFromGitHub,
  linuxPackages_6_6,
  linuxPackages_6_12,
  linuxPackages_6_15,
  ...
}:
let
  version = "6.0.0";
  bore-scheduler = fetchFromGitHub {
    owner = "firelzrd";
    repo = "bore-scheduler";
    rev = "38e4df81004bb5957cc06960765b5a850602da9c";
    hash = "sha256-2yvT/arD3m0sc41bqUVIz2ylZkjhMqbYgigmaTjaHHQ=";
  };

  kernelPatchInfo = {
    "6.6" = { revision = "97"; separator = "-bore"; };
    "6.12" = { revision = "37"; separator = "-bore"; };
    "6.15" = { revision = "6"; separator = "-bore"; };
  };

  getPatchesForKernel = kernelVersion:
    let
      patchInfo = kernelPatchInfo.${kernelVersion} or (throw "Unknown kernel version: ${kernelVersion}");
      patchFileName = "0001-linux${kernelVersion}.${patchInfo.revision}${patchInfo.separator}-${version}.patch";
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
      #{
      #  name = "bore-scheduler-ext-fix";
      #  patch = "${bore-scheduler}/patches/additions/0002-sched-ext-coexistence-fix.patch";
      #}
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
  linuxPackages_6_15_bore = makeKernelPackage linuxPackages_6_15 "6.15";
}
