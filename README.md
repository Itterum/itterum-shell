# Itterum Shell

Itterum Shell is an experimental [Quickshell](https://quickshell.org/) desktop shell for the [Niri](https://github.com/YaLTeR/niri) Wayland compositor. It is being rebuilt from the UI ideas and reusable assets of the Itterum Omarchy fork, with compositor integration provided by [qml-niri](https://github.com/imiric/qml-niri).

The project is in early development. The current shell provides a small top bar with Niri workspaces and information about the focused window. It is not yet a complete desktop environment or a drop-in replacement for Omarchy.

## Quick start

The development environment is defined by `flake.nix`. It supplies the qml-niri build of Quickshell, Qt development tools, and `just`.

With direnv and nix-direnv:

```bash
direnv allow
just run
```

Without direnv:

```bash
nix develop
just run
```

The shell must be started from a running Niri session so qml-niri can connect through `NIRI_SOCKET`.

## Development commands

```bash
just run      # Run the shell from this checkout
just check    # Evaluate the flake and lint active QML files
just lint     # Lint active QML files only
just info     # Show the selected development tools and Niri socket
```

`qmllint` is run with the QML import paths exported by the Nix development shell. The known static-analysis warning that treats Quickshell's `PanelWindow` as uncreatable is disabled; `PanelWindow` is created by Quickshell at runtime.

## Architecture

The compositor boundary is intentionally narrow:

```text
bar/widgets -> Compositor -> NiriBackend -> qml-niri -> Niri IPC
```

- `shell.qml` is the Quickshell entry point and creates a bar for each screen.
- `bar/` contains the panel and its widgets.
- `services/Compositor.qml` is the compositor-facing API used by UI code.
- `services/NiriBackend.qml` owns the qml-niri client and translates shell actions to Niri IPC calls.
- `themes/` contains retained Omarchy theme assets for future adaptation. They are not connected to the current shell yet, and some files remain Hyprland-specific.
- `legacy/omarchy/` is a reference snapshot of the previous Omarchy implementation. It is not part of the active runtime.

New widgets should depend on `Compositor`, not directly on qml-niri. This keeps Niri-specific details out of the UI and leaves room for the public shell API to evolve independently from its backend.

## Current scope

Implemented:

- one top bar per Niri output;
- live workspace state and workspace focusing;
- focused-window title;
- focusing and closing the active window.

Reusable UI components, theme loading, configuration, packaging, and additional system services will be added as the active shell grows. Empty architectural directories are deliberately avoided until they have a concrete consumer.

## Legacy code

The former Omarchy tree is retained under [`legacy/omarchy/`](legacy/omarchy/) while useful pieces are studied and ported. Active code must not import or execute files from that directory. A useful part should be copied into the active tree, adapted to Niri and the current service boundary, and tested there.

## License and credits

This repository remains available under the [MIT License](LICENSE). It is a fork-derived work and retains code and assets originating from [Omarchy](https://github.com/basecamp/omarchy), created by David Heinemeier Hansson and its contributors. Quickshell, qml-niri, and Niri are separate projects distributed under their respective licenses.
