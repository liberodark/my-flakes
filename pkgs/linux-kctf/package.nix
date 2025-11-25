{
  lib,
  fetchFromGitHub,
  linuxPackages_6_12,
  ...
}:
let
  kctfPatches = [
    ./patches/0001-mm-slub-randomize-the-cgroup-kmalloc-caches.patch
    ./patches/0002-mm-slub-add-is_slab_addr-is_slab_page-helpers.patch
    ./patches/0003-mm-slub-move-kmem_cache_order_objects-to-the-top-of.patch
    ./patches/0004-mm-use-virt_to_slab-instead-of-folio_slab.patch
    ./patches/0005-mm-slub-create-folio_set-clear_slab-helpers.patch
    ./patches/0006-mm-slub-pass-additional-args-to-alloc_slab_page.patch
    ./patches/0007-mm-slub-pass-slab-pointer-to-the-freeptr-decode-help.patch
    ./patches/0008-security-introduce-CONFIG_SLAB_VIRTUAL.patch
    ./patches/0009-mm-slub-add-the-slab-freelists-to-kmem_cache.patch
    ./patches/0010-x86-Create-virtual-memory-region-for-SLUB.patch
    ./patches/0011-mm-slub-allocate-slabs-from-virtual-memory.patch
    ./patches/0012-mm-slub-introduce-the-deallocated_pages-sysfs.patch
    ./patches/0013-mm-slub-sanity-check-freepointers.patch
    ./patches/0014-security-add-documentation-for-SLAB_VIRTUAL.patch
    ./patches/0015-mm-slub-reintroduce-guard-pages-for-SLAB_VIRTUAL.patch
    ./patches/0016-mm-slab_common-Add-CONFIG_KMALLOC_SPLIT_VARSIZE.patch
    ./patches/0017-slab-Adjust-placement-of-__kvmalloc_node_noprof.patch
    ./patches/0018-slab-Achieve-better-kmalloc-caches-randomization-in.patch
  ];

  makeKernelPackage =
    kernelPkg:
    let
      kernel = kernelPkg.kernel.override {
        ignoreConfigErrors = false;

        kernelPatches = map (p: {
          name = builtins.baseNameOf p;
          patch = p;
        }) kctfPatches;

        structuredExtraConfig = with lib.kernel; {
          NF_TABLES = lib.mkForce no;
          DRM_NOUVEAU_SVM = lib.mkForce (option no);
          NFT_REJECT_NETDEV = lib.mkForce (option no);
          NF_FLOW_TABLE_PROCFS = lib.mkForce (option no);
          NF_TABLES_ARP = lib.mkForce (option no);
          NF_TABLES_BRIDGE = lib.mkForce (option no);
          NF_TABLES_INET = lib.mkForce (option no);
          NF_TABLES_IPV4 = lib.mkForce (option no);
          NF_TABLES_IPV6 = lib.mkForce (option no);
          NF_TABLES_NETDEV = lib.mkForce (option no);
          STAGING_MEDIA = lib.mkForce (option no);

          # General hardening
          BUG_ON_DATA_CORRUPTION = yes;
          DEBUG_LIST = yes;
          HARDENED_USERCOPY = yes;
          FORTIFY_SOURCE = yes;
          SECURITY_DMESG_RESTRICT = yes;
          SECURITY_YAMA = yes;
          INIT_STACK_ALL_ZERO = yes;
          DEBUG_WX = yes;
          STACKPROTECTOR = yes;
          STACKPROTECTOR_STRONG = yes;
          VMAP_STACK = yes;
          RANDOMIZE_KSTACK_OFFSET = yes;
          RANDOMIZE_KSTACK_OFFSET_DEFAULT = yes;
          RANDOMIZE_BASE = yes;
          RANDOMIZE_MEMORY = yes;
          STRICT_KERNEL_RWX = yes;
          STRICT_MODULE_RWX = yes;
          X86_UMIP = yes;

          # CPU side channels
          MITIGATION_PAGE_TABLE_ISOLATION = yes;
          MITIGATION_RETPOLINE = yes;
          MITIGATION_IBPB_ENTRY = yes;
          MITIGATION_IBRS_ENTRY = yes;

          # Memory allocator
          SLUB = yes;
          SLAB_FREELIST_RANDOM = yes;
          SLAB_FREELIST_HARDENED = yes;
          SLAB_MERGE_DEFAULT = no;
          CGROUPS = yes;
          MEMCG = yes;

          # BPF
          SECCOMP = yes;
          SECCOMP_FILTER = yes;
          BPF_SYSCALL = yes;
          BPF_JIT = yes;
          BPF_JIT_ALWAYS_ON = lib.mkForce yes;
          BPF_UNPRIV_DEFAULT_OFF = yes;

          # Attack surface reduction
          #IO_URING = no;
          USERFAULTFD = lib.mkForce no;
          FUSE_FS = no;
          STAGING = lib.mkForce no;

          SLUB_TINY = no;
          KFENCE = lib.mkForce no;
          KASAN = no;

          # Extra mitigations
          #SLAB_VIRTUAL = yes;
          KMALLOC_SPLIT_VARSIZE = yes;
          RANDOM_KMALLOC_CACHES = yes;

          # Debug options
          #DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT = yes;
          #KALLSYMS = yes;
          #KALLSYMS_ALL = yes;
          #TRIM_UNUSED_KSYMS = no;
          #IKCONFIG = yes;
          #IKCONFIG_PROC = yes;
          #SLUB_DEBUG = yes;
        };
        extraMeta = {
          branch = "6.12";
          maintainers = with lib.maintainers; [ liberodark ];
          description = "Linux kernel with Google kernelCTF configuration";
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
  linuxPackages_6_12_kctf = makeKernelPackage linuxPackages_6_12;
}
