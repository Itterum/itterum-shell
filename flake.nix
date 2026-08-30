{
  description = "Itterum Shell development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qml-niri = {
      url = "github:imiric/qml-niri/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
  };

  outputs = { nixpkgs, qml-niri, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
    in
    {
      devShells = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              qml-niri.packages.${system}.quickshell
              pkgs.qt6.qtdeclarative
              pkgs.qt6.qttools
              pkgs.just
            ];

            QML_IMPORT_PATH = pkgs.lib.makeSearchPath "lib/qt-6/qml" [
              pkgs.qt6.qtdeclarative
              qml-niri.packages.${system}.quickshell
              qml-niri.packages.${system}.default
            ];
          };
        });
    };
}
