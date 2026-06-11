{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  glibc,
  icu,
  openssl,
  zlib,
  curl,
  libkrb5,
  lttng-ust,
  libxml2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "github-runner-riscv";
  version = "2.335.1";

  src = fetchurl {
    url = "https://github.com/Cloud-V-10xE/github-runner-riscv/releases/download/v${finalAttrs.version}-riscv64-net8/actions-runner-linux-riscv64-${finalAttrs.version}.tar.gz";
    hash = "sha256-8hwcDNx4cWajWbssNksk37HP15Oil5qZ+QI0F46c5a0=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    glibc
    icu
    openssl
    zlib
    curl
    libkrb5
    lttng-ust
    libxml2
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  appendRunpaths = [
    "${lib.getLib icu}/lib"
    "${lib.getLib openssl}/lib"
    "${lib.getLib libkrb5}/lib"
    "${lib.getLib zlib}/lib"
    "${lib.getLib curl}/lib"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/github-runner $out/bin

    cp -r . $out/lib/github-runner/

    chmod +x \
      $out/lib/github-runner/{config,run,runsvc,svc,env}.sh \
      $out/lib/github-runner/run-helper.sh* 2>/dev/null || true

    substituteInPlace $out/lib/github-runner/config.sh \
      --replace-fail './bin/Runner.Listener' "$out/bin/Runner.Listener" \
      --replace-warn 'command -v ldd' 'command -v ${glibc.bin}/bin/ldd' \
      --replace-warn 'command -v ldconfig' 'command -v ${glibc.bin}/bin/ldconfig' \
      --replace-warn '/sbin/ldconfig' '${glibc.bin}/bin/ldconfig' \
      --replace-warn 'ldd ./bin' "${glibc.bin}/bin/ldd $out/lib/github-runner/bin" \
      --replace-warn '$LDCONFIG_COMMAND -NXv ''${libpath//:/ }' 'echo libicu'

    for s in config run runsvc svc env; do
      if [ -f "$out/lib/github-runner/$s.sh" ]; then
        ln -s "$out/lib/github-runner/$s.sh" "$out/bin/$s.sh"
      fi
    done

    for bin in Runner.Listener Runner.Worker Runner.PluginHost; do
      if [ -f "$out/lib/github-runner/bin/$bin" ]; then
        makeWrapper "$out/lib/github-runner/bin/$bin" "$out/bin/$bin" \
          --run 'export RUNNER_ROOT="''${RUNNER_ROOT:-$PWD}"' \
          --run 'mkdir -p "$RUNNER_ROOT"'
      fi
    done

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    HOME=$TMPDIR $out/bin/config.sh --help
    HOME=$TMPDIR $out/bin/Runner.Listener --version

    runHook postInstallCheck
  '';

  meta = {
    description = "GitHub Actions Runner natively built for riscv64";
    homepage = "https://github.com/Cloud-V-10xE/github-runner-riscv";
    changelog = "https://github.com/Cloud-V-10xE/github-runner-riscv/releases/tag/v${finalAttrs.version}-riscv64-net8";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ liberodark ];
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "Runner.Listener";
  };
})
