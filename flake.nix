{
  description = "My Quickshell Niri setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    quickshell.url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, quickshell, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        quickshellPackage = quickshell.packages.${system}.default;
        itterumShell = pkgs.callPackage ./nix/package.nix {
          quickshell = quickshellPackage;
        };

        # Собираем все Qt зависимости в один список
        qtDeps = with pkgs.qt6; [
          qtdeclarative
          qtwayland
          qt5compat
        ];
      in
      {
        packages = {
          default = itterumShell;
          itterum-shell = itterumShell;
        };

        apps.default = {
          type = "app";
          program = pkgs.lib.getExe itterumShell;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            quickshellPackage
          ] ++ qtDeps;

          shellHook = ''
            # 1. Указываем Qt, где лежат QML-модули и плагины (исправляет ошибку Qt5Compat)
            export QML2_IMPORT_PATH="${pkgs.lib.makeSearchPath pkgs.qt6.qtbase.qtQmlPrefix qtDeps}"
            export QT_PLUGIN_PATH="${pkgs.lib.makeSearchPath pkgs.qt6.qtbase.qtPluginPrefix qtDeps}"

            # 2. Отключаем аппаратное ускорение OpenGL (исправляет ошибку EGL not available)
            export QT_QUICK_BACKEND=software
            export LIBGL_ALWAYS_SOFTWARE=1
          '';
        };
      }
    );
}
