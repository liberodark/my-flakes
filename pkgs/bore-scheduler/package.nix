{
  lib,
  fetchFromGitHub,
  linuxPackages_6_6,
  linuxPackages_6_12,
  linuxPackages_6_18,
  ...
}:
let
  version = "6.6.1";
  bore-scheduler = fetchFromGitHub {
    owner = "firelzrd";
    repo = "bore-scheduler";
    rev = "b73256bab82986f344ebb38c153ce5fdb0317bdc";
    hash = "sha256-56Va8VR51MEuV8Ma9nsUscx9X/pZ7ELv6HuYhpmdKBk=";
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
    "6.18" = {
      revision = "3";
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
    ++ lib.optionals (kernelVersion != "6.18") [
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
  linuxPackages_6_18_bore = makeKernelPackage linuxPackages_6_18 "6.18";
}
