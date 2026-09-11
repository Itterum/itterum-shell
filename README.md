# Itterum Shell

Itterum Shell is a **forked and refactored desktop shell** based on the Omarchy shell implementation.

## Not Omarchy

Itterum Shell is **not a Linux distribution**.

It is a standalone shell project that reuses and evolves the Omarchy UI/Quickshell work while decoupling distro-specific integration.

This means it is focused on the shell/runtime layer, not on package distribution, system installation, or update tooling.

## Current scope

The repository is moving toward:

- a stable Quickshell frontend
- a Rust daemon backend
- a compositor-agnostic architecture
- explicit service boundaries (audio/network/media/power/compositor)
- migration away from Omarchy-specific distribution assumptions

## CLI

Itterum Shell provides the `ish` command as its primary command-line interface.

`ish` is short for **Itterum Shell** and is intended to provide a single entry point for interacting with the shell and its runtime services.

The CLI will be used for operations such as:

```bash
ish status
ish reload
ish logs
ish doctor
```

As the runtime evolves, `ish` will also provide access to shell configuration, themes, services, compositor integrations, and other runtime functionality.

The project itself remains **Itterum Shell** (`itterum-shell`); `ish` is the short command name used for CLI interaction.

## Documentation

For shell architecture and implementation direction, start with:

- `docs/ARCHITECTURE.md`

The `manual/` directory currently contains mostly Omarchy historical documentation and is **not** authoritative for Itterum Shell runtime behavior.

## License

Itterum Shell is released under the [MIT License](https://opensource.org/licenses/MIT).
