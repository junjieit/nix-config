{ lib, stdenvNoCC, fetchurl }:

# ZeroClaw is not in nixpkgs yet (zeroclaw-labs/zeroclaw#5987) and the
# project's own flake cannot build its package (`nix/hashes.json` is out of
# sync with `Cargo.lock`, so `cargoDeps` fails to evaluate). Ship the
# upstream release binary until either of those lands, then drop this file
# and use nixpkgs' `pkgs.zeroclaw`.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zeroclaw";
  version = "0.8.5";

  src = fetchurl {
    url = "https://github.com/zeroclaw-labs/zeroclaw/releases/download/v${finalAttrs.version}/zeroclaw-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-5h5OKUTszAq3ks7sOM0pCkaeZh4kOWIkqdqErTRH5Og=";
  };

  # The archive holds the binaries plus a single `web/` directory; unpacking
  # would otherwise treat that directory as the source root.
  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  # The payload is a static musl binary; leave it byte-identical to the
  # release artefact so the fetch hash stays the integrity check.
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 zeroclaw $out/bin/zeroclaw
    mkdir -p $out/share/zeroclaw
    cp -r web/dist $out/share/zeroclaw/dist

    runHook postInstall
  '';

  meta = {
    description = "Fast, small AI assistant and agent runtime";
    homepage = "https://github.com/zeroclaw-labs/zeroclaw";
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "zeroclaw";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
