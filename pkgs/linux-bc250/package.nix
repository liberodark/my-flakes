{
  lib,
  bore-scheduler,
  ...
}:

let
  bc250Patches = [
    {
      name = "bc250-40cu-unlock";
      patch = ./bc250-40cu-amdgpu.patch;
    }
  ];

  makeBc250Kernel =
    boreKernelPackages:
    let
      kernel = boreKernelPackages.kernel.override (prev: {
        kernelPatches = prev.kernelPatches ++ bc250Patches;
        structuredExtraConfig =
          prev.structuredExtraConfig
          // (with lib.kernel; {
            HZ = freeform "1000";
            HZ_1000 = yes;
            HZ_250 = no;
          });
        extraMeta = {
          branch = prev.extraMeta.branch or "6.18";
          maintainers = with lib.maintainers; [ liberodark ];
          description = "Linux kernel with BORE scheduler + ASRock BC-250 patches";
        };
      });
    in
    boreKernelPackages.extend (_self: _super: { inherit kernel; });
in
{
  linuxPackages_6_18_bore_bc250 = makeBc250Kernel bore-scheduler.linuxPackages_6_18_bore;
}
