{ lib, stdenvNoCC, fetchurl, autoPatchelfHook, installShellFiles, alsa-lib, versionCheckHook }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "codex";
  version = "0.166.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@openai/codex/-/codex-${finalAttrs.version}-linux-x64.tgz";
    hash = "sha256-y8AKJtPQ4s7vxL6IkfioHvHjSbOxdbwK4wh2K8AB/ZM=";
  };

  nativeBuildInputs = [ autoPatchelfHook installShellFiles ];
  buildInputs = [ alsa-lib ];
  # GStreamer's audio backend loads ALSA dynamically.
  runtimeDependencies = [ alsa-lib ];
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -a vendor/x86_64-unknown-linux-musl/. $out/
    chmod -R u+w $out
    installShellCompletion --cmd codex \
      --bash <($out/bin/codex completion bash) \
      --fish <($out/bin/codex completion fish) \
      --zsh <($out/bin/codex completion zsh)
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "OpenAI Codex CLI (official release binaries)";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "codex";
    platforms = [ "x86_64-linux" ];
  };
})
