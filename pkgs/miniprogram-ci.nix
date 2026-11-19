{ lib, buildNpmPackage, nodejs, autoPatchelfHook, makeWrapper, stdenv }:

buildNpmPackage {
  pname = "miniprogram-ci";
  version = "2.1.31";

  # Install the published CLI as a dependency, without upstream's development tools.
  src = ./miniprogram-ci;
  npmDepsHash = "sha256-Z8LAjxxma63cEOkNkBXawJ0W207grD1O5ixcCVAYWWg=";
  npmFlags = [ "--legacy-peer-deps" ];
  npmInstallFlags = [ "--libc=glibc" ];
  # Native bindings are shipped in the optional platform packages. Patch them
  # during fixup instead of letting install scripts download fallback binaries.
  npmRebuildFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/miniprogram-ci"
    cp -r node_modules "$out/lib/miniprogram-ci/"
    makeWrapper ${lib.getExe nodejs} "$out/bin/miniprogram-ci" \
      --add-flags "$out/lib/miniprogram-ci/node_modules/miniprogram-ci/bin/miniprogram-ci.js"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/miniprogram-ci" --help > /dev/null
    ${lib.getExe nodejs} -e '
      const swc = require(process.argv[1]);
      swc.transformSync("const value = 1;", { jsc: { target: "es5" } });
    ' "$out/lib/miniprogram-ci/node_modules/@swc/core"
    runHook postInstallCheck
  '';

  meta = {
    description = "WeChat Mini Program compilation, preview and upload CLI";
    homepage = "https://developers.weixin.qq.com/miniprogram/dev/devtools/ci.html";
    license = lib.licenses.mit;
    mainProgram = "miniprogram-ci";
    platforms = [ "x86_64-linux" ];
  };
}
