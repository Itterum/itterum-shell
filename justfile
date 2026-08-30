qml_files := "shell.qml bar/Bar.qml bar/widgets/ActiveWindow.qml bar/widgets/Workspaces.qml services/Compositor.qml services/NiriBackend.qml"

default:
    @just --list

run:
    qs -p .

lint:
    qmllint -E --uncreatable-type disable {{qml_files}}

check: lint
    nix flake check

info:
    @printf 'qs: %s\n' "$(command -v qs)"
    @printf 'qmllint: %s\n' "$(command -v qmllint)"
    @printf 'QML_IMPORT_PATH: %s\n' "${QML_IMPORT_PATH:-<not set>}"
    @printf 'NIRI_SOCKET: %s\n' "${NIRI_SOCKET:-<not set>}"
