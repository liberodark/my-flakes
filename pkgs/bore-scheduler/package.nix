{
  lib,
  fetchFromGitHub,
  linuxPackages_6_6,
  linuxPackages_6_12,
  linuxPackages_6_17,
  ...
}:
let
  version = "6.5.9";
  bore-scheduler = fetchFromGitHub {
    owner = "firelzrd";
    repo = "bore-scheduler";
    rev = "10bd04bccaec437a0a3c20a0594c42264030cd3e";
    hash = "sha256-B3aN1eDqEnZRETttrvCsdMl6JTFaMzcAFgHrSTJf46k=";
  };

  kernelPatchInfo = {
    "6.6" = {
      revision = "107";
      separator = "-bore";
    };
    "6.12" = {
      revision = "37";
      separator = "-bore";
    };
    "6.17" = {
      revision = "4";
      separator = "-bore";
    };
  };

  getPatchesForKernel =
    kernelVersion:
    let
      patchInfo = kernelPatchInfo.${kernelVersion} or (throw "Unknown kernel version: ${kernelVersion}");
      patchFileName =
        if kernelVersion == "6.6" then
          "0001-linux6.6.107-bore5.9.6.patch"
        else
          "0001-linux${kernelVersion}${
            if patchInfo.revision != "" then ".${patchInfo.revision}" else ""
          }${patchInfo.separator}-${version}.patch";
    in
    [
      {
        name = "bore-scheduler";
        patch = "${bore-scheduler}/patches/stable/linux-${kernelVersion}-bore/${patchFileName}";
      }
    ]
    ++ lib.optionals (kernelVersion != "6.17") [
      {
        name = "bore-scheduler-smt";
        patch = "${bore-scheduler}/patches/stable/linux-${kernelVersion}-bore/0002-sched-fair-Prefer-full-idle-SMT-cores.patch";
      }
    ]
    ++ lib.optionals (kernelVersion == "6.17") [
      {
        name = "bore-prefer-previous-cpu";
        patch = "${bore-scheduler}/patches/stable/linux-${kernelVersion}-bore/0002-Prefer-the-previous-cpu-for-wakeup-v6.patch";
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
  linuxPackages_6_17_bore = makeKernelPackage linuxPackages_6_17 "6.17";
}
