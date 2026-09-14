{ lib, stdenvNoCC, quickshell }:

stdenvNoCC.mkDerivation {
  pname = "itterum-shell";
  version = "0.1.0";

  src = lib.cleanSource ../.;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d "$out/bin" "$out/libexec/itterum-shell" \
      "$out/share/itterum-shell/config"
    cp -R shell "$out/share/itterum-shell/shell"
    find "$out/share/itterum-shell/shell" -name README.md -delete
    install -Dm644 config/itterum-shell/shell.json \
      "$out/share/itterum-shell/config/shell.json"
    install -Dm644 config/itterum-shell/menu.jsonc \
      "$out/share/itterum-shell/config/menu.jsonc"

    substitute bin/itterum-shell "$out/libexec/itterum-shell/itterum-shell" \
      --replace-fail '@quickshell@' '${quickshell}' \
      --replace-fail '@resourcePath@' "$out/share/itterum-shell"
    chmod +x "$out/libexec/itterum-shell/itterum-shell"
    ln -s "$out/libexec/itterum-shell/itterum-shell" \
      "$out/bin/itterum-shell"

    runHook postInstall
  '';

  meta = {
    description = "Declarative Quickshell desktop shell for Itterum NixOS";
    license = lib.licenses.mit;
    mainProgram = "itterum-shell";
    platforms = lib.platforms.linux;
  };
}
