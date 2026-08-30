# Project Scope

Itterum Shell is an experimental Quickshell desktop shell for Niri. The active implementation lives at the repository root:

- `shell.qml` is the runtime entry point.
- `bar/` contains the panel and bar-specific widgets.
- `services/` contains runtime integrations and public service facades.
- `themes/` contains retained theme assets that are not yet wired into the shell.
- `flake.nix`, `.envrc`, and `justfile` define the local development workflow.

`legacy/omarchy/` is reference material from the previous Omarchy tree. Read it when porting an idea, but do not fix, format, test, import, or execute it as part of active shell work unless the task explicitly targets the archive. Move useful behavior into the active tree and adapt it there.

# Architecture Boundaries

- UI components use `services/Compositor.qml` as the compositor API.
- `services/NiriBackend.qml` is the only active QML file that should import `Niri` or call qml-niri directly.
- Do not add active Hyprland imports, `hyprctl` calls, or dependencies on files under `legacy/omarchy/`.
- Keep UI presentation in widgets and system/compositor behavior in services.
- Add a shared `components/` directory only when a component is genuinely reused by more than one feature.
- Keep services flat while the directory remains small. Introduce service subdirectories only when separate domains have multiple related files.

# QML Conventions

- Follow `.editorconfig`; active QML uses four-space indentation.
- Name QML component files with `PascalCase` and object IDs and properties with `camelCase`.
- Give non-trivial component roots an `id` such as `root`, `panel`, or `shell`.
- Expose singleton services through a `qmldir` file and keep their public properties read-only where practical.
- Keep backend-specific types behind a service facade rather than leaking them into reusable UI APIs.
- Prefer bindings and model-driven components over imperative polling.
- Preserve the local style of files you are not otherwise changing.

# Development Environment

Enter the Nix development environment before running project tools:

```bash
direnv allow
```

or:

```bash
nix develop
```

Use the repository commands:

- `just run` starts the current checkout with `qs -p .`.
- `just lint` runs `qmllint` against active QML only.
- `just check` evaluates the flake and runs the QML lint check.
- `just info` prints the selected tools, QML import path, and Niri socket.

Do not modify the user's NixOS or Home Manager configuration as part of normal shell development. Keep project dependencies in `flake.nix`.

# Verification

- Run `just check` after documentation, Nix, or QML changes that affect the development workflow.
- Run visual changes inside an actual Niri session and inspect Quickshell logs for QML or IPC errors.
- Confirm workspace and window actions against the active Niri session when compositor behavior changes.
- Generated `.qmlls.ini` and `.direnv/` content must remain untracked.
- Do not count warnings from files under `legacy/omarchy/` as active project failures.

# Documentation

- Keep `README.md` limited to behavior and commands that currently exist.
- Document planned features as future scope, not as implemented functionality.
- When the architecture outgrows the README, add focused documents under `docs/` instead of duplicating explanations.
- Keep `CLAUDE.md` as the compatibility entry point that imports `AGENTS.md`.

# Git

- Preserve unrelated user changes in the working tree.
- Keep commits atomic and do not combine active shell work with cleanup inside `legacy/omarchy/`.
- Review large legacy moves with rename detection enabled so unchanged files are recognizable as moves rather than rewrites.
