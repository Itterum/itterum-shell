# Task: Extract Omarchy Quattro into a portable CachyOS runtime

## Status

Planned. This document is a task specification for a future implementation agent.

## Repository

`https://github.com/Itterum/itterum-shell`

## Goal

Turn the Omarchy Quattro desktop shell in this fork into a standalone desktop runtime that can be installed and used on an existing **CachyOS + Hyprland** system without converting that system into Omarchy and without applying Omarchy's OS-level configuration.

Preserve as much upstream Quattro as possible:

- Quickshell shell
- bar
- workspace UI
- menu / launcher
- notifications
- OSD
- tray
- audio
- Bluetooth
- network
- monitor controls
- power widget
- theme system
- wallpaper/background integration where reasonably portable
- plugin system
- user shell configuration

Do **not** install or apply the Omarchy distribution layer.

Upstream compatibility is a primary requirement. Prefer selecting and adapting runtime files over rewriting upstream QML.

---

## Branch strategy

Do **not** implement this work on `feature/niri-backend`.

That branch is the experimental Niri-native rewrite and must remain independent.

Use the synchronized Quattro tree as the implementation base.

Implementation branch:

`feature/cachyos-runtime`

Before coding:

1. Ensure `omacom/omarchy` exists as the `upstream` remote.
2. Fetch upstream.
3. Confirm the fork's `quattro` branch is synchronized with the intended upstream Quattro revision.
4. Create `feature/cachyos-runtime` from that synchronized Quattro branch.
5. Record the upstream commit used as the baseline in this document or the implementation PR.

Do not mix the Niri port into this task.

---

## Architectural principle

Treat Omarchy as two layers:

```text
Omarchy
├── desktop runtime        <- KEEP
│   ├── Quickshell
│   ├── shell plugins
│   ├── bar
│   ├── menu
│   ├── themes
│   ├── notifications
│   ├── OSD
│   └── selected helpers
│
└── operating-system layer <- DO NOT INSTALL
    ├── bootloader
    ├── mkinitcpio
    ├── sysctl
    ├── PAM defaults
    ├── SDDM configuration
    ├── NetworkManager provisioning
    ├── zram / oomd
    ├── sudoers
    ├── package-manager hooks
    ├── installation scripts
    └── distribution branding
```

The target machine must remain CachyOS.

---

## Compatibility strategy

Preserve Omarchy's internal runtime namespace wherever possible.

Keep:

```text
OMARCHY_PATH=/usr/share/omarchy
```

Keep runtime paths such as:

```text
/usr/share/omarchy/shell
/usr/share/omarchy/themes
/usr/share/omarchy/config
/usr/share/omarchy/default
```

Keep `omarchy-*` helper command names where the command itself is portable.

Do not perform a mass rename to `itterum-*` inside upstream-derived QML or helpers.

The Arch package itself may be named:

`itterum-shell`

while preserving Omarchy-compatible internal runtime paths.

This is intentional: minimizing source divergence should make future merges from `upstream/quattro` practical.

---

# Phase 1 — Audit the runtime boundary

Before removing or packaging anything, produce a dependency audit starting from:

```text
shell/shell.qml
```

Trace:

- first-party shell plugins
- helper executables invoked from QML
- configuration files
- theme files
- user/system services
- external commands and packages

Classify every required `omarchy-*` command into one of these groups.

### A — Portable runtime helper

Can run unchanged on ordinary Arch/CachyOS.

Typical examples may include helpers based on:

- `wpctl`
- `bluetoothctl`
- `nmcli`
- `brightnessctl`
- `ddcutil`
- `wl-copy`
- `jq`

Include these.

### B — Portable with adaptation

Useful feature, but assumes an Omarchy environment.

Create the smallest compatibility adapter necessary.

### C — Omarchy OS management

Examples:

- bootloader management
- system installation
- Omarchy distribution updates
- SDDM provisioning
- system networking provisioning
- Docker/security provisioning
- Plymouth
- snapshot configuration
- sysctl
- kernel configuration

Do not ship these as part of the runtime.

### D — Optional feature

The shell can function without it.

Keep these optional instead of adding large dependency chains.

Document the audit under this file or a focused follow-up document such as:

`docs/cachyos-runtime.md`

---

# Phase 2 — Create an Arch/CachyOS package

Add packaging for a standalone Arch package.

Suggested location:

```text
packaging/arch/
├── PKGBUILD
└── ...
```

Package name:

`itterum-shell`

The package must install only the desktop runtime.

At minimum, evaluate and explicitly select the required portions of:

```text
shell/
themes/
config/omarchy/
default/themed/
default/omarchy/
bin/
version
```

Only include `bin/` commands actually required by the retained runtime.

Avoid blindly copying entire upstream directories.

Maintain an explicit runtime manifest or install list so upstream additions do not silently acquire system-level behavior.

---

## Forbidden package contents

`itterum-shell` MUST NOT install or modify:

```text
/etc/os-release
/etc/security/*
/etc/pam.d/*
/etc/sysctl.d/*
/etc/modprobe.d/*
/etc/mkinitcpio*
/etc/limine*
/etc/sddm*
/etc/systemd/system/*
/etc/systemd/oomd*
/etc/systemd/zram*
/etc/sudoers*
/etc/udev/*
```

Do not install:

- Limine
- Snapper configuration
- Plymouth configuration
- Omarchy SDDM configuration
- Omarchy pacman hooks
- installation migrations
- ISO/install scripts
- Omarchy OS branding

Do not depend on:

```text
omarchy
omarchy-settings
```

Installing `itterum-shell` must never cause `omarchy-settings` to be installed.

---

# Phase 3 — Runtime environment and launch

Provide a reliable way to start the shell while keeping:

```bash
OMARCHY_PATH=/usr/share/omarchy
```

Reuse upstream shell launch infrastructure where safe, especially:

```text
omarchy-shell
omarchy-launch-shell
```

Avoid duplicating Quickshell process-management logic unnecessarily.

Provide an Itterum/CachyOS-facing entry point if useful, for example:

```text
itterum-shell
```

that prepares the required environment and delegates to the upstream-compatible launcher.

Do not automatically edit the user's Hyprland configuration from a package install script.

Document an explicit autostart command the user can add.

The runtime should be usable both manually and from Hyprland autostart.

---

# Phase 4 — Minimal safe shell configuration

Do not initially enable every upstream Omarchy feature.

Create a CachyOS-safe default shell configuration approximately equivalent to:

```text
left:
  menu
  workspaces

center:
  clock

right:
  tray
  bluetooth
  network
  audio
  monitor
  power
```

Initially omit or disable features with strong Omarchy OS assumptions:

```text
omarchy.system-update
lock
idle
polkit
```

Do not fake functionality for these.

The shell should remain usable when optional features are disabled.

---

# Phase 5 — Menu portability

Keep the upstream Quattro menu UI.

Do not rewrite the menu implementation merely because some actions are Omarchy-specific.

Audit actions from the Omarchy menu definition.

For every action:

- retain it if portable;
- adapt it if there is a clean CachyOS equivalent;
- hide/remove it from the CachyOS default menu if it manages the Omarchy operating system.

The resulting menu must not expose commands that are guaranteed to fail or that would mutate CachyOS into Omarchy.

Review especially:

```text
Install
Remove
Update
Setup
DNS
Plymouth
Docker/security setup
Omarchy update
system provisioning
```

System actions such as:

```text
lock
logout
suspend
hibernate
reboot
shutdown
```

may remain once they point to safe host-independent implementations.

---

# Phase 6 — Update widget

Do not retain Omarchy's update implementation unchanged.

The upstream widget assumes the Omarchy update pipeline through commands such as:

```text
omarchy-update-available
omarchy-update
```

For the initial MVP it is acceptable and preferable to omit:

`omarchy.system-update`

If implementing a CachyOS version in this task, create a small host-facing adapter with no Omarchy migration or repository logic.

Availability can be determined using normal Arch mechanisms such as `checkupdates`.

Do not hard-code an AUR helper unless the project explicitly chooses one.

---

# Phase 7 — Themes

Preserve the Quattro theme engine and its runtime state layout where possible.

The shell should continue to understand Omarchy-compatible state paths such as:

```text
~/.local/state/omarchy/current/theme
```

Do not rewrite QML theme consumers merely to rename the state directory.

Port only theme helpers needed to:

- select a shell theme;
- expose theme colors to Quickshell;
- switch shell/background assets where safe.

Do not carry over theme actions that modify unrelated OS components such as:

- Plymouth
- bootloader
- browser/system policies
- system branding

Theme switching must not write unrelated system configuration.

---

# Phase 8 — Notifications and OSD

Prefer enabling the Quattro implementations.

Document that only one notification daemon should own:

`org.freedesktop.Notifications`

at a time.

Do not forcibly uninstall or disable the user's current notification daemon during package installation.

The user must be able to opt into the Quattro notification service.

OSD should work through the normal Quattro shell IPC mechanism.

---

# Phase 9 — Lock, idle, and polkit

These are explicitly secondary features.

Do not compromise the MVP by trying to integrate all three immediately.

For the first working runtime:

- existing CachyOS lock solution may remain;
- existing idle daemon may remain;
- existing Polkit agent may remain.

Do not install Omarchy PAM configuration automatically.

If lock integration is implemented later, treat PAM changes as a separate security-sensitive change with its own review and tests.

Do not silently replace PAM or authentication configuration.

---

# Dependencies

Determine dependencies from the actually retained runtime instead of copying `install/omarchy-base.packages`.

Expected core dependencies will probably include some subset of:

```text
hyprland
quickshell
uwsm
pipewire
wireplumber
networkmanager
bluez
bluez-utils
brightnessctl
ddcutil
wl-clipboard
wtype
jq
gum
perl
git
ttf-jetbrains-mono-nerd-basic
noto-fonts-emoji
```

Do not add applications such as browsers, LibreOffice, Docker, OBS, editors, etc. merely because Omarchy installs them by default.

Optional plugin dependencies should remain optional where practical.

---

# Preserve upstream mergeability

This is a major acceptance requirement.

Avoid unnecessary modifications inside:

```text
shell/
```

Prefer:

```text
packaging/
compat/
small helper wrappers
CachyOS-specific default config
```

over large changes to upstream QML.

When an upstream file must be modified:

1. keep the change narrowly scoped;
2. document why the change cannot live in an adapter;
3. avoid renaming unrelated symbols or reformatting files.

A future upstream merge should produce a small, understandable compatibility diff.

---

# Do not touch the Niri implementation

Do not modify or merge work from:

`feature/niri-backend`

The existing Niri architecture is a separate experiment.

Long-term, a common compositor facade may be desirable, but that is explicitly outside this task.

---

# Testing

Add automated checks where practical.

## Package

Verify:

```bash
makepkg
namcap PKGBUILD
```

The package must build on an Arch/CachyOS environment.

Inspect the built package contents.

There must be no unintended `/etc` files, bootloader configuration, system provisioning, or Omarchy installer payload.

## Shell smoke test

With only declared runtime dependencies installed, starting the runtime should successfully launch Quickshell.

Verify:

- bar appears;
- no fatal QML errors;
- workspace list is live;
- clicking a workspace switches workspace;
- clock works;
- tray loads;
- audio status works;
- network status works;
- Bluetooth widget loads when Bluetooth exists;
- monitor widget does not crash when unsupported;
- power widget loads;
- menu opens;
- disabled/unsupported features do not crash the shell.

## Config

Verify that:

```text
~/.config/omarchy/shell.json
```

continues to override the packaged default.

## Theme

Verify at least two bundled themes and ensure changing a theme updates the shell without requiring an Omarchy installation.

## Isolation test

On CachyOS, after package installation verify that these remain unchanged:

```text
/etc/os-release
bootloader configuration
PAM configuration
NetworkManager configuration
SDDM configuration
sysctl configuration
```

---

# Acceptance criteria

The work is complete when all of the following are true:

1. `itterum-shell` builds as a standalone Arch package.
2. It does not depend on `omarchy` or `omarchy-settings`.
3. It can be installed on an existing CachyOS + Hyprland machine.
4. Installation does not modify or replace CachyOS system configuration.
5. Quattro Quickshell starts from `/usr/share/omarchy/shell`.
6. `OMARCHY_PATH=/usr/share/omarchy` remains the compatibility contract.
7. Core bar widgets work.
8. Workspaces can be switched through Hyprland.
9. The menu contains only working/safe entries for the CachyOS runtime.
10. Theme switching works without changing unrelated system configuration.
11. No Omarchy boot, installer, migration, or distro-management layer is installed.
12. The diff against upstream Quattro remains small and understandable.
13. `feature/niri-backend` remains untouched.
14. Documentation explains installation, launch, dependencies, known unsupported features, and the upstream-sync strategy.

---

# Deliverables

Implementation branch:

```text
feature/cachyos-runtime
```

Expected deliverables:

- runtime extraction/package implementation;
- Arch/CachyOS `PKGBUILD`;
- explicit runtime file/dependency selection;
- necessary compatibility helpers;
- CachyOS-safe shell/menu defaults;
- tests/smoke checks;
- `docs/cachyos-runtime.md` or equivalent implementation documentation;
- README section explaining CachyOS/Hyprland support.

Suggested commit structure:

```text
build: add standalone itterum-shell package
feat: add portable quattro runtime
feat: add cachyos-safe shell defaults
feat: adapt menu for portable runtime
feat: port standalone theme support
test: add cachyos runtime smoke checks
docs: document cachyos runtime
```

Before finishing, provide a summary containing:

- upstream Quattro baseline commit;
- files copied unchanged from upstream;
- files modified relative to upstream;
- omitted Omarchy components;
- runtime dependencies;
- optional dependencies;
- known unsupported Quattro features;
- exact commands for installation and startup on CachyOS;
- recommendations for keeping the fork synchronized with future upstream Quattro changes.

---

# Agent handoff

A future implementation agent can be instructed with:

> Implement `docs/tasks/cachyos-quattro-runtime.md` in `Itterum/itterum-shell`. Start from the synchronized `quattro` branch, create `feature/cachyos-runtime`, follow the specification and acceptance criteria exactly, keep the diff against upstream Quattro minimal, and do not touch `feature/niri-backend`.
