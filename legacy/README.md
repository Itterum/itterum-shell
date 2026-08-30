# Legacy sources

This directory contains code and assets retained as reference material while Itterum Shell is rebuilt around Quickshell, qml-niri, and Niri.

`omarchy/` is a snapshot of the previous Omarchy-based repository tree. It is intentionally tracked for now, but it is not part of the active shell, development checks, or runtime import paths.

When reusing something from the snapshot:

1. understand the behavior and its dependencies;
2. copy only the required part into the active repository structure;
3. replace Hyprland-specific behavior with the appropriate service abstraction;
4. test the adapted implementation in the active tree.

Do not make opportunistic formatting or maintenance changes inside the snapshot. Once the migration no longer needs an in-tree reference, the snapshot can be replaced by a Git branch or tag.
